import Foundation

enum FloatingPanelCommand: Equatable {
    case useChinese
    case useEnglish
    case useSettingsDefault
    case toggleMultiLanguageOutput
    case selectPreviousOutput
    case selectNextOutput
    case commitSelected
    case cancel
    case translateNow
    case retry
    case stop
}
