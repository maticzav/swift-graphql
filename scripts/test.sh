#!/bin/bash

swift build

for example in examples/**
do
    echo "👀 Generating ${example}"
    swift run swift-graphql https://swift-swapi.herokuapp.com/ --config "${example}/swiftgraphql.yml" --output "${example}/StarWars/API.swift"

    echo "🧘‍♂️ Building ${example}"
    swift build --package-path ${example}

    echo "✅  Built ${example}"
done


