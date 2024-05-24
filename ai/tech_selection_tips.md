# 2024年 AIマイクロサービスのプロジェクト構成とLLM選定
## LLM
- ローカルLLMは使わない
  - 大手のOpenAIには勝てない。。。
  - あくまでもそれをうまく使うことに注力
    - Azure OpenAI
    - Anthropic Claude3 Opus
      - AWS Bedrockで使いやすい
      - プロンプトのチューニングなしで優しい口調になっている => プロンプトのトークン節約
      - 『ベンタの機能差と価格(インフラも含めた)を考慮して選ぼう』
        - コンテンツフィルター
        - function-calling
