#!/bin/bash
# DONE install in bashrc
# DONE call and parse sreport
# DONE write timestamp, if current time is further than a week, send the message
# DONE remove discord channel id from source
# TODO push github
# TODO instructions in README
# TODO ask someone to test
# TODO share with group


WEBHOOK_URL=https://discord.com/api/webhooks/$DISCORD_CHANNEL_ID
USAGE_FILE=partition-usage.txt
CMDNAME=reporter


install() {
    echo "Installing tool in bashrc/zshrc using DISCORD_CHANNEL_ID=$1"
    # TODO handle DISCORD_CHANNEL_ID
    # Detect if bashrc or zshrc by current shell
    # could be paths like /usr/bin/bash, /bin/bash, usr/bin/zsh, /bin/zsh
    DISCORD_CHANNEL_ID=$1
    shell=$(basename $SHELL)
    if [[ $shell == "bash" ]]; then
        rcfile=$HOME/.bashrc
    elif [[ $shell == "zsh" ]]; then
        rcfile=$HOME/.zshrc
    else
        echo "Could not determine shell from $SHELL"
        exit 1
    fi

    if [[ ! -f $rcfile ]]; then
        echo "Could not find rc file at $rcfile"
        exit 1
    fi

    # Check if the tool already exists in the rcfile
    if [[ -z $(grep "$CMDNAME" $rcfile) ]]; then
        # Adds in bashrc or zshrc a hook to launch the script and also set there
        # the discord channel environment variable
        echo "" >> $rcfile
        echo "# >>> cluster-reporter" >> $rcfile
        echo "# This will run the script on login." >> $rcfile
        echo "# This will do nothing if the script has already run in the last while." >> $rcfile
        echo "export DISCORD_CHANNEL_ID=$DISCORD_CHANNEL_ID" >> $rcfile
        echo "$CMDNAME () {" >> $rcfile
        echo "  if [[ -f $SCRIPT_PATH ]]; then" >> $rcfile
        echo "      $SCRIPT_PATH \$@" >> $rcfile
        echo "  fi" >> $rcfile
        echo "}" >> $rcfile
        echo "$CMDNAME run" >> $rcfile
        echo "# >>> cluster-reporter" >> $rcfile
        echo "" >> $rcfile
    fi

    # Tell user to relogin or source to run the first report
    echo "Done!"
    echo ""
    echo "Installed command \`$CMDNAME\` into $rcfile"
    echo "You may need to relogin or else run \`source $rcfile\`"
}


update_usage_and_send_discord() {
  # Compute usage in file and send it to discord
  sreport -P -t hour --tres=gres/gpu cluster UserUtilizationByAccount Start=1970-01-01 End=now user "$USER" > $USAGE_FILE
  echo $USAGE_FILE

  # Parse the output from sreport and sum the "Used" column
  # Skip header lines, extract the last field from each line, and sum them
  GPU_HOURS=$(awk -F'|' '/^kislurm/ {sum += $NF} END {print sum}' $USAGE_FILE)
  echo "Total GPU hours: $GPU_HOURS"

  # Send compute usage to Discord
  # We send the total across partitions, we could also send it per account / per partition
  MESSAGE="${USER}, $(hostname), GPU hours: ${GPU_HOURS}"
  curl -H "Content-Type: application/json" \
       -d "{\"content\": \"$MESSAGE\"}" \
       $WEBHOOK_URL
}

run() {
  # Sends the report if it has not been sent since a week by checking if the report file is less recent than a week old
  if [ -f "$USAGE_FILE" ]; then
      # Get the current time in seconds since epoch
      CURRENT_TIME=$(date +%s)

      # Get the file's last modification time in seconds since epoch
      FILE_TIME=$(stat -c %Y "$USAGE_FILE")

      # Calculate the age of the file in seconds
      FILE_AGE=$((CURRENT_TIME - FILE_TIME))

      # One week in seconds = 7 days * 24 hours * 60 minutes * 60 seconds
      ONE_WEEK=$((7 * 24 * 60 * 60))

      # Check if file is older than a week
      if [ "$FILE_AGE" -gt "$ONE_WEEK" ]; then
          echo "Report not send since a week, regenerating it and sending to discord"
          update_usage_and_send_discord
      else
          echo "Report already sent in less than a week, not resending."
      fi
  else
      echo "No previous report, regenerating it and sending to discord"
      update_usage_and_send_discord
  fi
}

# either install the script or run it given the passed argument
command=$1
if [[ $command == "install" ]]; then
    SCRIPT_PATH="${HOME}/report-discord.sh"
    echo "Installing to $SCRIPT_PATH"
    echo "This will inject the script into your shell rc file."
    echo "This will allow you to run the script by typing \`$CMDNAME\`"
    echo ""
    DISCORD_CHANNEL_ID=$2
    install $DISCORD_CHANNEL_ID
    exit 0
elif [[ $command == "run" ]]; then
    run
else
    run
fi
