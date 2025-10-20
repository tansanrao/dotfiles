# Rosé Pine Dawn (light) variant

# Theme options (shared across variants)
set -g @rose_pine_host 'on'
set -g @rose_pine_hostname_short 'on'
set -g @rose_pine_date_time ''
set -g @rose_pine_user 'on'
set -g @rose_pine_directory 'off'
set -g @rose_pine_bar_bg_disable 'off'
set -g @rose_pine_bar_bg_disabled_color_option 'default'
set -g @rose_pine_only_windows 'off'
set -g @rose_pine_disable_active_window_menu 'on'
set -g @rose_pine_default_window_behavior 'on'
set -g @rose_pine_show_current_program 'on'
set -g @rose_pine_show_pane_directory 'on'

# Separators & icons
set -g @rose_pine_left_separator ' > '
set -g @rose_pine_right_separator ' < '
set -g @rose_pine_field_separator ' | '
set -g @rose_pine_window_separator ' - '
set -g @rose_pine_session_icon ''
set -g @rose_pine_current_window_icon ''
set -g @rose_pine_folder_icon ''
set -g @rose_pine_username_icon ''
set -g @rose_pine_hostname_icon '󰒋'
set -g @rose_pine_date_time_icon '󰃰'
set -g @rose_pine_window_status_separator "  "

# The only difference: variant = dawn (light)
set -g @rose_pine_variant 'dawn'

# (Re)apply theme
set -g status on

