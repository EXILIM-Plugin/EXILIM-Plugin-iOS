# EXILIM-Plugin-iOS について

EXILIM-Plugin-iOSは、iOS版 Device Connectプラットフォームである [DeviceConnect-iOS](https://github.com/DeviceConnect/DeviceConnect-iOS/) でカシオ計算機製のデジタルカメラである EXILIM シリーズを利用できるようにするためのカシオ計算機公式のプラグインです。

# API仕様
本プラグインのAPI仕様は以下に公開しています。
- [EXILIM-Plugin API](https://exilim-plugin.github.io/exilimApi/)

# アーキテクチャ

本プラグインはバイナリ形式のiOS フレームワークとして提供されています(ソースコードは非公開)。

iOSで Device Connectおよびそのプラグインを利用するためには、Webブラウザを内蔵した iOSアプリ(以下ブラウザアプリ)を作成し、そのアプリに本プラグインを組み込む必要があります。
ブラウザアプリとしては [DeviceWebAPIBrowser](https://itunes.apple.com/jp/app/devicewebapibrowser/id994422987?mt=8) が AppStoreに公開されておりますが、iOSは完成されたアプリに後からプラグイン(Framework)を追加することができないため、本プラグインを利用するためにはブラウザアプリをソースコードから再ビルドし、ビルド時にプラグインを含める必要があります。

そこで、本プラグインを利用するために最小限の機能を持ったブラウザアプリのソースコードを以下に公開しています。

- [EXILIM-Plugin-iOS-ControllerApp](https://github.com/EXILIM-Plugin/EXILIM-Plugin-iOS-ControllerApp)

以下、この EXILIM-Plugin-iOS-ControllerApp を例にして、プラグインの組み込み方法を解説します。


# プラグインの組み込み方法

## 詳細仕様

- 動作確認カメラ
  - EXILIM EX-FR100
  - EXILIM EX-FR200
  - EXILIM EX-FR100KT
- 対応 OS
  - iOS 9.0 以上
- 動作確認済み Xcode バージョン
  - Xcode 9.2
- 対応 Swift バージョン
  - Swift 4.0
  - ※ 本プラグインは Swiftで実装されているため、異なるバージョンの Swiftランタイムでは正常に動作しない可能性があります。
- 依存ライブラリ
  - DeviceConnectSDK (2.2.10)
    - CocoaAsyncSocket (7.6.1)
    - CocoaHTTPServer (2.3.1)
    - CocoaLumberjack (3.3.0)
    - RoutingHTTPServer (1.0.0)
  - ReachabilitySwift (4.1.0)
  - RxAutomaton (0.2.1) swift/4.0 ブランチを使用すること
  - RxCocoa (4.2.1)
  - RxSwift (4.2.1)



## CocoaPods

EXILIM-Plugin-iOS-ControllerApp の Podfileは以下のような構造になっています。

```
source 'https://github.com/EXILIM-Plugin/EXILIM-Plugin-iOS-PodSpecs.git'
source 'https://github.com/kunichiko/DeviceConnect-PodSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
swift_version = '4.0'
use_frameworks!

target 'ExilimDeviceController' do
  pod 'DeviceConnectSDK', '= 2.2.10'
  pod 'DeviceConnectHostPlugin'
  pod 'DeviceConnectExilimPlugin'

  pod 'RxAutomaton', :git => 'https://github.com/inamiy/RxAutomaton.git', :branch => 'swift/4.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'

      # https://github.com/robbiehanson/CocoaHTTPServer/issues/171
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'DD_LEGACY_MACROS=1']
    end
  end
end
```

### source (Specファイルの読み込みソース) の追加

本プラグインは、Podfileに以下のように記述することで追加可能です。

```
  pod 'DeviceConnectExilimPlugin'
```

ただし、CocoaPods 本家の PodSpecリポジトリには登録されていないため、Podfileの先頭に以下の記述を追加する必要があります。

```
source 'https://github.com/EXILIM-Plugin/EXILIM-Plugin-iOS-PodSpecs.git'
```

また、依存している DeviceConnectSDK は 2.2.10ですが、こちらのスペックが [DeviceConnect-iOS本家の PodSpecリポジトリ](https://github.com/DeviceConnect/DeviceConnect-PodSpecs.git)には登録されていないため、以下の source の追加が必要です。

```
source 'https://github.com/kunichiko/DeviceConnect-PodSpecs.git'
```

[プルリクエスト](https://github.com/DeviceConnect/DeviceConnect-PodSpecs/pull/2)がマージされ次第、こちらの URLは `https://github.com/DeviceConnect/DeviceConnect-PodSpecs.git` に変更になります。

### RxAutomatonを swift/4.0ブランチに変更

RxSwift 4に対応した RxAutomatonはまだ正式にリリースされていませんが、swift/4.0ブランチにて対応が行われていますので、そちらを参照する必要があります。

Podfileに以下の記述を追加してください。

```
  pod 'RxAutomaton', :git => 'https://github.com/inamiy/RxAutomaton.git', :branch => 'swift/4.0'
```

### 環境設定

本プラグインは、「iOS 9以上」、「Swift 4」、「フレームワーク使用」を前提としているため、以下を記述しています。

```
platform :ios, '9.0'
swift_version = '4.0'
use_frameworks!
```

なお、Swift 3環境で利用したい場合は、DeviceConnectExilimPlugin 0.3.0をご利用ください。

### ワークアラウンド

DeviceConnect SDKが依存している CocoaHTTPServerが[ビルドエラーになる問題](https://github.com/robbiehanson/CocoaHTTPServer/issues/171)があるため、各ビルドの `GCC_PREPROCESSOR_DEFINITIONS` 設定に `DD_LEGACY_MACROS=1` を追加しています。

# 制限事項

## 他プラグインとの共存について

上記 EXILIM-Plugin-iOS-ControllerApp の Podspec には Hostプラグインが追加されているため、Hostプラグインの機能と EXILIMプラグインの機能が両方利用可能です。
Hostプラグイン同様、必要なプラグインをPodfileに追加することで、他のプラグインとの同時利用も可能になりますが、弊社では動作確認などは行っておりません。

# ライセンス

本プラグインは [MIT ライセンス](LICENSE.md)のもと、バイナリ形式でのみ配布いたします。
