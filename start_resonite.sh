#!/bin/sh

cd ${STEAMAPPDIR}/Headless
exec dotnet Resonite.dll -HeadlessConfig /Config/Config.json -l /Logs
