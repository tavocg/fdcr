#!/bin/sh
case "${1-}" in
  firmador:*)
    origin=${1#firmador:}
    shift
    set -- "-Djnlp.remoteOrigin=$origin" -jar @jar@ "$@"
    ;;
  *)
    set -- -jar @jar@ "$@"
    ;;
esac
exec @java@ "$@"
