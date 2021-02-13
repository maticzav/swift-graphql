#!/bin/bash

swift build

for example in examples/**
do
    echo "👀 Generating ${example}"
    swift run swift-graphql http://localhost:4000 --config "${example}/swiftgraphql.yml" --output "${example}/StarWars/API.swift"

    echo "🧘‍♂️ Building ${example}"
    swift build --package-path ${example} -c release

    echo "✅  Built ${example}"
done


