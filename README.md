# cluster-report-discord

A tool that reports slurm compute usage on Discord automatically every week.

### Install

Run the following to install the script:
```bash
DISCORD_CHANNEL_ID=...
wget -q -O "${HOME}/cluster_reporter.sh" "https://ml.informatik.uni-freiburg.de/research-artifacts/automl-private/cluster-reporter/cluster_reporter.sh" \
  && chmod +x "${HOME}/cluster_reporter.sh" \
  && "${HOME}/cluster_reporter.sh" install $DISCORD_CHANNEL_ID
```

If your group communicated a channel-id, use this one. 
Otherwise, see next section to create one to report compute on a new channel.

### Getting the channel-id


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
