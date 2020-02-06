{% import_yaml 'components/defaults.yaml' as defaults %}

Stage - Reset Core:
  cmd.run:
    - name: __slot__:salt:setup_conf.conf_cmd('/opt/seagate/eos/core/conf/setup.yaml', 'core:reset')

Remove EOSCore package:
  pkg.purged:
    - pkgs:
      - mero
      # - mero-debuginfo

Delete EOSCore yum repo:
  pkgrepo.absent:
    - name: {{ defaults.eoscore.repo.id }}

Delete eoscore checkpoint flag:
  file.absent:
    - name: /opt/seagate/eos-prvsnr/generated_configs/{{ grains['id'] }}.eoscore
