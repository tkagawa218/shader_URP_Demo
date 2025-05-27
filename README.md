# 🔥 URP炎シェーダーデモ - HLSL × Emission × ノイズゆらぎ

![デモGIF](Docs/flame.gif)

Unity URP + HLSL を使用して作成したリアルタイム炎エフェクトのデモプロジェクトです。  
ノイズによる揺らぎ表現とUV歪みで自然な動きを演出し、Emission × Bloomでリアルな発光を再現しています。

---

## 🎯 使用技術

- Unity 6.x
- URP（Universal Render Pipeline）
- HLSL（手書きカスタムシェーダー）
- Emission Map × Emission Color × Emission Intensity
- Gradient Noise（Legacy方式）
- Radial Shear（UV歪みによる上昇表現）

---

## 🔍 特徴

- ノイズによるゆらぎとUV歪みによる炎の自然な動き
- Emission + Bloom を活用したリアルなGlow表現
- アルファ値による滑らかなフェードアウト
- シンプルな構成で再利用しやすいShader設計

---

## 🚀 セットアップ方法

1. Unity 6.0 以降のバージョンで本リポジトリをクローン
2. `Assets/FireShader/Scenes/DemoScene.unity` を開く
3. `Project Settings > Graphics` から URP アセットが正しく設定されていることを確認
4. 再生ボタンで炎エフェクトを確認できます

---

## 📂 フォルダ構成
Assets/
└── FireShader/
├── Shaders/ // HLSLシェーダー本体
├── Materials/ // 使用するマテリアル
├── Scenes/ // デモシーン
└── Textures/ // ノイズ・エミッション画像など
Docs/
└── flame.gif // 実演GIF

---

## 💡 今後の追加予定（ToDo）

- Flow Noise による炎のさらなる自然表現
- カスタムマスク対応
- Shader Graph版の併用例
- WebGLデモの公開

---

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。  
詳細は [LICENSE](LICENSE) ファイルをご確認ください。

