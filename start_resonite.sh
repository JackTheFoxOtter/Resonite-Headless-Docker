#!/bin/sh

cd ${STEAMAPPDIR}/Headless/net8.0
exec dotnet Resonite.dll -HeadlessConfig /Config/Config.json -l /Logs
