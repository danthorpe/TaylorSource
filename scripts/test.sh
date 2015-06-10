#!/usr/bin/env bash
source /usr/local/opt/chruby/share/chruby/chruby.sh
chruby ruby
echo ''gem: --no-ri --no-rdoc'' > ~/.gemrc
bundle install
pushd "framework"
pod install
xcodebuild -workspace "TaylorSource.xcworkspace" -configuration Debug -sdk iphonesimulator -scheme TaylorSource clean build test | xcpretty -c && exit ${PIPESTATUS[0]}
popd

