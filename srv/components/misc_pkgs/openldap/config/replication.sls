Configure openldap syncprov_mod:
  cmd.run:
    - name: ldapadd -Y EXTERNAL -H ldapi:/// -f /opt/seagate/eos-prvsnr/generated_configs/ldap/syncprov_mod.ldif

Configure openldap syncprov:
  cmd.run:
    - name: ldapadd -Y EXTERNAL -H ldapi:/// -f /opt/seagate/eos-prvsnr/generated_configs/ldap/syncprov.ldif
    - require:
      - Configure openldap syncprov_mod 

Configure openldap replication:
  cmd.run:
    - name: ldapadd -Y EXTERNAL -H ldapi:/// -f /opt/seagate/eos-prvsnr/generated_configs/ldap/replicate.ldif
    - watch_in:
      - service: Restart Slapd
    - require:
      - Configure openldap syncprov

Restart Slapd:
  service.running:
    - name: slapd
    - full_restart: True
