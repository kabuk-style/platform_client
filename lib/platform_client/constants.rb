# frozen_string_literal: true

module PlatformClient
  DEFAULT_LANGUAGE = 'en-US'
  JAPANESE_LANGUAGE = 'ja-JP'
  KOREAN_LANGUAGE = 'ko-KR'
  TAIWANESE_LANGUAGE = 'zh-TW'
  SUPPORTED_LANGUAGES = [DEFAULT_LANGUAGE, JAPANESE_LANGUAGE].freeze

  # Extended list of languages supported other requests like check_rate
  EXT_SUPPORTED_LANGUAGES = [DEFAULT_LANGUAGE, JAPANESE_LANGUAGE, KOREAN_LANGUAGE, TAIWANESE_LANGUAGE].freeze

  DEFUAULT_NATIONALITY = 'JP'
end
