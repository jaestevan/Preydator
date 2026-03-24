---@diagnostic disable
-- Preydator: koKR (Korean) localization
-- Credit: koKR localization by Elnarfim
if GetLocale() ~= "koKR" then return end
local L = _G.PreydatorL

---- Stage defaults (displayed in the progress bar; players can override in Options > Text)
  L["No Sign in These Fields"]   = "이 지역에 흔적 없음"
  L["AMBUSH"]                    = "매복"
  L["Bloody Command"]            = "핏빛 명령"
  L["Scent in the Wind"]         = "바람 속의 냄새"
  L["Blood in the Shadows"]      = "그림자 속의 피"
  L["Echoes of the Kill"]        = "살육의 메아리"
  L["Feast of the Fang"]         = "송곳니의 향연"

---- Options panel tabs
  L["General"]    = "일반"
  L["Display"]    = "표시"
  L["Vertical"]   = "세로"
  L["Text"]       = "텍스트"
  L["Audio"]      = "오디오"
  L["Currencies"] = "화폐"
  L["Advanced"]   = "고급"

---- Section headers
  L["Visibility"]            = "표시 여부"
  L["Behavior"]              = "동작"
  L["Hunt Table"]            = "사냥 탁자"
  L["Currencies"]            = "화폐"
  L["Bar Size"]              = "바 크기"
  L["Progress Display"]      = "진행 상황 표시"
  L["Visual Style"]          = "시각적 스타일"
  L["Vertical Mode"]         = "세로 모드"
  L["Vertical Dimensions"]   = "세로 크기"
  L["Label Mode"]            = "레이블 모드"
  L["Prefix Labels"]         = "접두사 레이블"
  L["Label Placement"]       = "레이블 위치"
  L["Suffix Labels"]         = "접미사 레이블"
  L["Sound Selection"]       = "효과음 선택"
  L["Custom Files / Tests"]  = "사용자 정의 파일 / 테스트"
  L["Restore / Reset"]       = "복구 / 초기화"
  L["Notes"]                 = "참고"

---- Checkboxes
  L["Lock Bar"]                          = "바 잠금"
  L["Only show in prey zone"]            = "사냥감 구역에서만 표시"
  L["Disable Default Prey Icon"]         = "기본 사냥감 아이콘 비활성화"
  L["Show in Edit Mode preview"]         = "편집 모드 미리보기에 표시"
  L["Enable Hunt Table Tracker"]         = "사냥 탁자 추적기 활성화"
  L["Enable sounds"]                     = "효과음 활성화"
  L["Ambush sound alert"]                = "매복 효과음 경보"
  L["Ambush visual alert"]               = "매복 시각 경보"
  L["Bloody Command sound alert"]        = "핏빛 명령 효과음 경보"
  L["Bloody Command visual alert"]       = "핏빛 명령 시각 경보"
  L["Show tick marks"]                   = "눈금 표시"
  L["Display Spark Line"]                = "스파크 라인 표시"
  L["Link border color to fill"]         = "테두리 색상을 채우기 색상과 연결"
  L["Show Percentage at Tick Marks"]     = "눈금에 백분율 표시"
  L["Enable Debug"]                      = "디버그 활성화"
  L["Currency Debug Events"]             = "화폐 디버그 이벤트"
  L["Show Minimap Button"]               = "미니맵 버튼 표시"
  L["Show Affordable Hunts In Tracker"]  = "추적기에 수행 가능한 사냥 표시"
  L["Show Group By Realm In Warband"]    = "전투 부대를 서버마다 그룹으로 표시"
  L["Show bar during Edit Mode"]         = "편집 모드 중에 바 표시"

---- Dropdown field titles
  L["Currency Theme"]           = "화폐 테마"
  L["Progress Segments"]        = "진행도 구분"
  L["Sound Channel"]            = "효과음 채널"
  L["Hunt Panel Side"]          = "사냥 패널 위치"
  L["Bar Orientation"]          = "바 방향"
  L["Vertical Fill Direction"]  = "세로 채우기 방향"
  L["Vertical Text Side"]       = "세로 텍스트 위치"
  L["Vertical Text Alignment"]  = "세로 텍스트 정렬"
  L["Vertical Percent Display"] = "세로 백분율 표시"
  L["Vertical Percent Tick Mark"] = "세로 백분율 눈금"
  L["Percent Display"]          = "백분율 표시"
  L["Text Display"]             = "텍스트 표시"
  L["Texture"]                  = "텍스처"
  L["Title Font"]               = "제목 글꼴"
  L["Percent Font"]             = "백분율 글꼴"
  L["Ambush Sound"]             = "매복 효과음"
  L["Bloody Command Sound"]     = "핏빛 명령 효과음"

---- Slider labels
  L["Scale"]                 = "크기 비율"
  L["Width"]                 = "너비"
  L["Height"]                = "높이"
  L["Font Size"]             = "글꼴 크기"
  L["Enhance Sounds"]        = "소리 증폭"
  L["Vertical Text Offset"]  = "세로 텍스트 간격"
  L["Vertical Percent Offset"] = "세로 백분율 간격"

---- Sound dropdown labels (dynamic Stage N format)
  L["Stage %d Sound"] = "%d단계 효과음"

---- Text input labels
  L["Stage %d"]              = "%d단계"
  L["Out of Zone Prefix"]    = "구역 외 접두사"
  L["Ambush Prefix"]         = "매복 접두사"
  L["Out of Zone Label"]     = "구역 외 레이블"
  L["Ambush Override Text"]  = "매복 대체 텍스트"
  L["Custom Sound File"]     = "사용자 정의 효과음 파일"

---- Color buttons
  L["Fill Color"]        = "채우기 색상"
  L["Background Color"]  = "배경 색상"
  L["Title Color"]       = "제목 색상"
  L["Percent Color"]     = "백분율 색상"
  L["Tick Mark Color"]   = "눈금 색상"
  L["Border Color"]      = "테두리 색상"

---- Action buttons
  L["Restore Default Names"]   = "기본 이름으로 복구"
  L["Restore Default Sounds"]  = "기본 효과음으로 복구"
  L["Reset All Defaults"]      = "모든 설정 초기화"
  L["Add File"]                = "파일 추가"
  L["Remove File"]             = "파일 제거"
  L["Test Stage %d"]           = "%d단계 테스트"
  L["Test Ambush"]             = "매복 테스트"
  L["Test Bloody Command"]     = "핏빛 명령 테스트"
  L["Show What's New"]         = "새로운 기능 보기"

---- Dropdown option values — Texture
  L["Default"]          = "기본값"
  L["Flat"]             = "단색"
  L["Raid HP Fill"]     = "공격대 생명력"
  L["Classic Skill Bar"] = "클래식 숙련도 바"

---- Dropdown option values — Font
  L["Friz Quadrata"]  = "Friz Quadrata"
  L["Arial Narrow"]   = "Arial Narrow"
  L["Skurri"]         = "Skurri"
  L["Morpheus"]       = "Morpheus"

---- Dropdown option values — Sound channel
  L["Master"]   = "주 음량"
  L["SFX"]      = "효과"
  L["Dialog"]   = "대화"
  L["Ambience"] = "환경 소리"

---- Dropdown option values — Currency theme
  L["Light"]  = "밝게"
  L["Brown"]  = "갈색"
  L["Dark"]   = "어둡게"

---- Dropdown option values — Percent display
  L["In Bar"]      = "바 내부"
  L["Above Bar"]   = "바 위"
  L["Above Ticks"] = "눈금 위"
  L["Under Ticks"] = "눈금 아래"
  L["Below Bar"]   = "바 아래"
  L["Off"]         = "끄기"

---- Dropdown option values — Tick layer
  L["Above Fill"] = "채우기 위"
  L["Below Fill"] = "채우기 아래"

---- Dropdown option values — Progress segments
  L["Quarters (25/50/75/100)"] = "4등분 (25/50/75/100)"
  L["Thirds (33/66/100)"]      = "3등분 (33/66/100)"

---- Dropdown option values — Label mode
  L["Centered"]                 = "중앙 정렬"
  L["Left (Prefix only)"]       = "왼쪽 (접두사만)"
  L["Left (Prefix + Suffix)"]   = "왼쪽 (접두사 + 접미사)"
  L["Left (Suffix only)"]       = "왼쪽 (접미사만)"
  L["Right (Suffix only)"]      = "오른쪽 (접미사만)"
  L["Right (Prefix + Suffix)"]  = "오른쪽 (접두사 + 접미사)"
  L["Right (Prefix only)"]      = "오른쪽 (접두사만)"
  L["Separate (Prefix + Suffix)"] = "분리 (접두사 + 접미사)"
  L["No Text"]                  = "텍스트 없음"

---- Dropdown option values — Label row
  L["Above Bar"] = "바 위"
  L["Below Bar"] = "바 아래"

---- Dropdown option values — Orientation
  L["Horizontal"] = "가로"
  L["Vertical"]   = "세로"

---- Dropdown option values — Vertical fill
  L["Fill Up"]   = "위로 채우기"
  L["Fill Down"] = "아래로 채우기"

---- Dropdown option values — Sides
  L["Left"]   = "왼쪽"
  L["Right"]  = "오른쪽"
  L["Center"] = "중앙"

---- Dropdown option values — Vertical text align
  L["Top Align"]           = "상단 정렬"
  L["Middle Align"]        = "중앙 정렬"
  L["Bottom Align"]        = "하단 정렬"
  L["Top Prefix Only"]     = "상단 접두사만"
  L["Top Suffix Only"]     = "상단 접미사만"
  L["Bottom Prefix Only"]  = "하단 접두사만"
  L["Bottom Suffix Only"]  = "하단 접미사만"
  L["Separate Prefix/Suffix"] = "접두사/접미사 분리"

---- Dropdown option values — Vertical percent display (short form)
  L["Above"]  = "위"
  L["Inside"] = "내부"
  L["Below"]  = "아래"

---- Hint/note blocks
  L["HINT_VERTICAL_PERCENT_OFFSET"] = "세로 백분율 간격은 세로 측면 또는 눈금 측면 배치 시 적용됩니다. 단일 백분율 값 대신 눈금을 사용하세요."
  L["HINT_VERTICAL_LOCK"]           = "세로 모드에서는 레이블 모드와 접두사/접미사 행만 잠깁니다. 단계 이름과 사용자 정의 레이블은 계속 편집할 수 있습니다."
  L["HINT_AUDIO_SLIDER"]            = "슬라이더 값은 드래그하거나 직접 입력할 수 있습니다. 사용자 정의 효과음에는 파일 이름, .ogg 또는 전체 애드온 경로를 입력하세요."
  L["HINT_ADVANCED_NOTES"]          = "기존 설치 환경은 현재 저장된 값을 유지합니다. 새 설정은 PreydatorDB에 키가 없을 때만 적용됩니다. 이 패널은 이전의 긴 옵션 페이지를 대체하지만 동일한 데이터베이스를 사용합니다. 조사 기능은 BugSack과 호환됩니다."
  L["HINT_PANEL_SUBTITLE"]          = "두 개의 열로 구성된 탭 레이아웃 옵션입니다. 슬라이더 값은 드래그하거나 직접 입력할 수 있습니다."
  L["HINT_EDITMODE_SUBTITLE"] = "블리자드 기본 편집 모드가 열려 있는 동안 사용할 수 있는 빠른 레이아웃 설정입니다. 전체 옵션은 '설정 > 애드온 > Preydator'에서 확인할 수 있습니다."

---- Print / chat messages
  L["Preydator: Added sound file '%s'."]    = "Preydator: 효과음 파일 '%s'|1을;를; 추가했습니다."
  L["Preydator: Removed sound file '%s'."]  = "Preydator: 효과음 파일 '%s'|1을;를; 제거했습니다."
  L["Preydator: No stage %d sound configured."] = "Preydator: %d단계 효과음이 설정되지 않았습니다."
  L["Preydator: Stage %d sound file failed to play. Ensure this file exists as .ogg: %s"] = "Preydator: %d단계 효과음 파일 재생에 실패했습니다. 해당 경로에 .ogg 파일이 있는지 확인하세요: %s"

---- EditMode window
  L["Preydator Edit Mode"]       = "Preydator 편집 모드"
  L["HINT_EDITMODE_SUBTITLE"]    = "블리자드 편집 모드가 열려 있는 동안 사용할 수 있는 간편 레이아웃 설정입니다. 전체 옵션은 설정 > 애드온 > Preydator에서 확인하세요."

---- Currency Tracker windows
  L["Preydator Currency"]        = "Preydator 화폐"
  L["Preydator Warband"]         = "Preydator 전투부대"
  L["Currency Tracker"]          = "화폐 추적기"
  L["Preydator Updates: New in 2.1.1"] = "Preydator 업데이트: 2.1.1 새로운 기능"
  L["Got It"]                    = "확인"
  L["Open Settings"]             = "설정 열기"
  L["Toggle Tracker"]            = "추적기 켜기/끄기"
  L["Toggle Warband"]            = "전투부대 켜기/끄기"
  L["Open Tracker"]              = "추적기 열기"
  L["Close Tracker"]             = "추적기 닫기"
  L["Open Warband"]              = "전투부대 열기"
  L["Close Warband"]             = "전투부대 닫기"
  L["Gain Color"]                = "획득 색상"
  L["Spend Color"]               = "소비 색상"

---- Hunt Table companion panel
  L["Preydator Hunt Tracker"]                          = "Preydator 사냥 추적기"
  L["Available Hunts"]                                 = "가능한 사냥"
  L["Rewards unknown"]                                 = "보상 알 수 없음"
  L["Reward data pending"]                             = "보상 데이터 대기 중"
  L["No available hunts"]                              = "가능한 사냥 없음"
  L["Use /pd huntdebug at a hunt table to print payload data."] = "사냥 탁자에서 /pd huntdebug를 입력하여 데이터를 확인하세요."

---- Currency config page labels
  L["Currencies to Track"]          = "추적할 화폐"
  L["Random Hunt Cost (Anguish)"]   = "무작위 사냥 비용 (고뇌)"
  L["Panel Layout"]                 = "패널 레이아웃"
  L["Adjust"]                       = "조정"
  L["Delta Preview"]                = "변동치 미리보기"
  L["Normal"]                       = "일반"
  L["Hard"]                         = "어려움"
  L["Nightmare"]                    = "악몽"
  L["Currency Window"]              = "화폐 창"
  L["Warband Window"]               = "전투부대 창"

---- Warband column headers
  L["Realm"]     = "서버"
  L["Character"] = "캐릭터"
  L["Anguish"]   = "고뇌"
  L["Voidlight"] = "공허불빛"
  L["Adv"]       = "모험가"
  L["Vet"]       = "노련가"
  L["Champ"]     = "챔피언"
  L["N/H/Ni"]    = "일/어/악"

---- Warband dynamic row labels
  L["Total"]     = "합계"
  L["All Realms"] = "모든 서버"
  L["Totals"]    = "총계"
  L["Subtotal"]  = "소계"

---- Currency tracker summary format
  L["Normal %d | Hard %d | Nightmare %s"] = "일반 %d | 영웅 %d | 신화 %s"

---- Modules page
  L["Module Status"]                                                                                    = "모듈 상태"
  L["Bar Module"]                                                                                       = "바 모듈"
  L["Controls the main prey progress bar display and behavior."]                                       = "주요 사냥감 진행 바의 표시 및 동작을 설정합니다."
  L["Sounds Module"]                                                                                    = "효과음 모듈"
  L["Controls stage sounds and ambush audio settings."]                                                = "단계별 효과음 및 매복 오디오 설정을 설정합니다."
  L["Currency Module"]                                                                                  = "화폐 모듈"
  L["Controls the currency tracker panel and currency displays."]                                      = "화폐 추적 패널 및 화폐 표시를 설정합니다."
  L["Hunt Table Module"]                                                                               = "사냥 탁자 모듈"
  L["Controls hunt table data, sorting, and panel features."]                                          = "사냥 탁자 데이터, 정렬 및 패널 기능을 설정합니다."
  L["Warband Module"]                                                                                   = "전투부대 모듈"
  L["Controls the warband currency panel and roster view."]                                            = "전투부대의 화폐 패널 및 명단 보기를 설정합니다."
  L["Achievement Module"]                                                                              = "업적 모듈"
  L["Coming soon: achievement tracking is not available yet."]                                         = "준비 중: 업적 추적 기능은 아직 사용할 수 없습니다."
  L["Reload"]                                                                                           = "UI 재시작"
  L["Module changes require a reload to fully apply. Achievement module remains disabled until it is released."] = "모듈 변경 사항을 완전히 적용하려면 UI 재시작이 필요합니다. 업적 모듈은 출시 전까지 비활성화 상태로 유지됩니다."

---- Minimap / LDB tooltip
  L["Left Click: Toggle Currency Window"]  = "왼쪽 클릭: 화폐 창 켜기/끄기"
  L["Right Click: Toggle Warband Window"]  = "오른쪽 클릭: 전투부대 창 켜기/끄기"
  L["Shift + Right Click: Open Options"]   = "Shift + 오른쪽 클릭: 설정 열기"
  L["Preydator Currency Tracker"]          = "Preydator 화폐 추적기"

