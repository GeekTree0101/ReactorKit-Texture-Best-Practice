import ReactorKit
import RxSwift
import UIKit

final class SignUpFieldReactor: Reactor {
    
    struct Const {
        static let passwordMinimumValidCount: Int = 6
    }
    
    enum Scope {
        case email
        case password
        
        var returnKeyType: UIReturnKeyType {
            return self == .email ? .next: .join
        }
        
        var keyboardType: UIKeyboardType {
            return self == .email ? .emailAddress: .default
        }
        
        var clearsOnInsertion: Bool {
            return self == .password ? true: false
        }
        
        var isSecureTextEntry: Bool {
            return self == .password ? true: false
        }
        
        var placeholderString: String {
            switch self {
            case .email: return "What's your email?"
            case .password: return "Password"
            }
        }
    }
    
    enum FieldStatus {
        case wrong
        case valid
        
        var attribute: [NSAttributedString.Key: Any] {
            switch self {
            case .wrong: return [.font: UIFont.systemFont(ofSize: 12.0), .foregroundColor: UIColor.invalid]
            case .valid: return [.font: UIFont.systemFont(ofSize: 12.0), .foregroundColor: UIColor.valid]
            }
        }
        
        func text(_ scope: Scope) -> String {
            switch self {
            case .wrong:
                return scope == .email ?
                    "Please enter a valid email address": "Please enter a valid password"
            case .valid:
                return scope == .email ?
                    "Email looks great": "Password looks great"
            }
        }
        
        func message(_ scope: Scope) -> NSAttributedString {
            return NSAttributedString.init(string: self.text(scope), attributes: self.attribute)
        }
    }
    
    enum Action {
        case editingChanged(Scope?, String?)
    }
    
    enum Mutation {
        case setStatus(Scope?, String?)
    }
    
    struct State {
        var message: NSAttributedString?
        var fieldStatus: FieldStatus = .wrong
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .editingChanged(let scope, let text):
            return Observable.just(.setStatus(scope, text))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStatus(let scope, let text):
            guard let text = text, let scope = scope else {
                return state
            }
            
            if text.isEmpty {
                newState.message = nil
                newState.fieldStatus = .wrong
                return newState
            }
            
            let fieldStatus: FieldStatus
            
            switch scope {
            case .email:
                fieldStatus = text.isValidEmail() ? .valid: .wrong
            case .password:
                fieldStatus =
                    text.count > Const.passwordMinimumValidCount ? .valid: .wrong
            }
            
            newState.fieldStatus = fieldStatus
            newState.message = fieldStatus.message(scope)
        }
        
        return newState
    }

}
