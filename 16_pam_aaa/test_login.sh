#!/bin/bash
if getent group adm_group | grep &>/dev/null $PAM_USER; then

    exit 0;
fi

if [ $(date +%u) -gt 5 ];then

  exit 1;

else

   exit 0;

fi