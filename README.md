# tq-cliedit
simple cli based editor for Titan quest(popular arpg) save files.
it can handle 2 character directories. the second is of course for the custom map characters.
i was sick and tired of the windows ui based one cause i am a linux user so i wanted something that works natively,
i also didnt need a lot of the fancy features.
so use it on YOUR OWN RISK, NO WARRANTIES AT ALL.

it can
  - safe main stashes to files
  - give any char about 2 billion gold
  - safe waypoint data to files
  - load waypoint and stash files back into main characters

requirements:
  - ruby v > 3.0
  - titan quest with save games on local machine
  - config file adjusted to tq character folders

installation:
  - install ruby version 3 or higher
  - edit configuration
      - adding the exact locations of the char directories on your machine
        - tip for easier use: create symlinks, otherwise this gets messy
      - add whatever dirs you want to use to store item, wps files
      - make sure all directories exist

usage:
  - call using ruby tq-cliedit.rb

tested on titanquest on linux, ragnarok and atlantis extension
so use it on YOUR OWN RISK, NO WARRANTIES AT ALL.