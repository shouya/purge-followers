## Purge unwanted followers:

1. `bundle install`
1. `cp keywords{.default,}.txt`
1. `cp run{.default,}.sh`
1. Edit keyword backlist file `keywords.txt`, keywords separated by any blank characters
1. Review and edit the rule in [`report.rb`](report.rb) (inside `examine` function)
1. `sh run.sh report.rb`
1. (optional) modify `run.sh` and save `TWITTER_ACCESS_TOKEN` and `TWITTER_ACCESS_SECRET` variable
1. Review and edit the `THRESHOLD` in [`purge.rb`](purge.rb), followers below this score will be purged.
1. Edit the generated `report.txt` and exclude follower entries you want to preserve
1. `sh run.sh purge.rb`


(MIT License)
