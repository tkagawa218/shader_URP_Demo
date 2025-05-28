# URP Fire Shader Demo

UnityのURPとHLSLを用いた、簡易的な炎エフェクトシェーダーのデモです。EmissionやUVノイズ、歪み表現を活用し、揺らめく炎を表現しています。

## 🎮 実演デモ

[WebGLデモはこちら](https://tkagawa218.itch.io/urp-fire-shader-webgl-demo)

※現在、一部ブラウザでピンクの四角のみ表示される不具合があります。詳細は「今後の課題」セクションをご参照ください。

## 🔧 構成

- URP向けのHLSLカスタムシェーダー
- ノイズ生成 + UVアニメーションによる動き
- Emissionマップによる発光制御
- マテリアル制御によるインスペクタ調整

## 📂 使用方法

1. Unity 2022.3 以降でプロジェクトを開く
2. URPアセットとRendererを Graphics/Quality に設定
3. `FireWithEmission.shader` を任意のマテリアルに適用
4. デモシーンを開いて再生

## ⚠ 今後の課題・改善予定

- WebGL上でのピンク表示（Fallback Shader表示）
  - `Hidden/InternalErrorShader` が参照される問題
  - 原因：Render Pipeline設定 / Shaderターゲット互換性の問題
- 対応予定：
  - Shader Graph版への移行
  - Shader Model 2.0 準拠の軽量版
  - HDR/Bloomを省いたWebGL特化Renderer構成

## 📜 ライセンス

MITライセンス。自由に改変・商用利用可能です。
