# logrotate.d
Setup logrotate policy for rabbitmq-server:
  file.managed:
  - name: /etc/logrotate.d/rabbitmq-server
  - source: salt://components/sspl/files/etc/logrotate.d/rabbitmq-server
  - keep_source: False
  - user: root
  - group: root

{% set role = pillar['sspl']['role'] %}
# Copy conf file to /etc/sspl.conf
Copy sample file:
  file.copy:
    - name: /etc/sspl.conf
    - source: /opt/seagate/sspl/conf/sspl.conf.{{ pillar['sspl']['SYSTEM_INFORMATION']['product'] }}
    - mode: 644
    - require:
        - pkg: Install sspl packages

Update SSPL config:
  module.run:
    - sspl.conf_update:
      - name: /etc/sspl.conf
      - ref_pillar: sspl
      - backup: True

{% if 'virtual' in salt['grains.get']('productname').lower() %}
{% set role = 'vm' %}

# Execute only on Virtual Machine
Update sspl-ll conf file:
  file.replace:
    - name: /etc/sspl.conf
    - pattern: ^system\s*=\s*.+
    - repl: setup = vm

#Update sspl config file with pillar data:
#  module.run:
#    - eosconfig.update
#      - name: /etc/sspl.conf
#      - ref_pillar: sspl
#      - type: YAML
#      - backup: True

{% else %}

Add zabbix user in sudoers file:
  file.line:
    - name: /etc/sudoers
    - content: 'zabbix ALL=(ALL) NOPASSWD: ALL'
    - mode: ensure
    - after: '.*%wheel\s+ALL=\(ALL\)\s+NOPASSWD:\s*ALL'
    - backup: True
    - require:
        - pkg: sudo

# Create sudoers file for zabbix user:
#   file.managed:
#     - name: /etc/sudoers.d/zabbix
#     - makedirs: True
#     - replace: True
#     - mode: 644
#     - contents:
#       - 'zabbix ALL=(ALL) NOPASSWD: ALL'
    
Ensure directory dcs_collector.conf.d exists:
  file.directory:
    - name: /etc/dcs_collector.conf.d
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode

Ensure file dcs_collector.conf exists:
  file.managed:
    - name: /etc/dcs_collector.conf
    - contents: |
        # Placeholder configuration. New configuration will be generated by Puppet.
        [general]
        config_dir=/etc/dcs_collector.conf.d/

        [hpi]

        [hpi_monitor]
    - require:
      - file: Ensure directory dcs_collector.conf.d exists

#Start service dcs-collector:
#  cmd.run:
#    - name: /etc/rc.d/init.d/dcs-collector start
#    - onlyif: test -f /etc/rc.d/init.d/dcs-collector
#    - require:
#      - file: Ensure file dcs_collector.conf exists

# END: Prepare for SSPL configuration

{% endif %}

Execute sspl_init script:
  cmd.run:
    - name: /opt/seagate/sspl/sspl_init config -f -r {{ role }}
    - onlyif: test -f /opt/seagate/sspl/sspl_init
