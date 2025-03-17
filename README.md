# cluster-report-discord

A tool that reports slurm compute usage on Discord automatically every week.

### Install

You must first set the discord channel id:
```bash
DISCORD_CHANNEL_ID=12345678910/ABCDEFGZ
```
given what was communicated by your team.

If you want to create one for your discord channel, see next section to create one.

Then run the following to install the script:
```bash
wget -q -O "${HOME}/report-discord.sh" "https://raw.githubusercontent.com/OpenEuroLLM/cluster-report-discord/refs/heads/main/report-discord.sh" \
  && chmod +x "${HOME}/report-discord.sh" \
  && "${HOME}/report-discord.sh" install $DISCORD_CHANNEL_ID
```

### Getting the channel-id of a discord channel


To create one for a channel, click on the setting wheel of a channel "Edit Channel", 
then click on "Integrations", "Webhooks", then "New Webhook".

Then click on the webhook that was created and click on "Copy Webhook URL", you will obtain something like this:

```
https://discord.com/api/webhooks/12345678910/ABCDEFGZ
```

use the last part for the discord channel id `DISCORD_CHANNEL_ID=12345678910/ABCDEFGZ`.

### Run

The tool runs automatically at most once per week. 
When login into the machine, the script checks if the file '~/partition-usage.txt' is older than 
a week, if so it gets updated and send a compute report to discord with this form:

```
salinasd, CLUSTERNAME, GPU hours: 3953
```

To see a small report of the script, set `export REPORT_VERBOSE=1` in your bashrc/zshrc.

### Acknowledgement

The tool is based on a previous version made by Eddie Bergman and Ivo Ranpant.
It has been adapted to support Discord instead of Mattermost and simplified a bit.