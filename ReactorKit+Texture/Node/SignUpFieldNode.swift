import AsyncDisplayKit
import ReactorKit
import RxCocoa_Texture
import RxSwift
import RxOptional

class SignUpFieldNode: ASDisplayNode & View {
    
    struct Const {
        static let indicatorLineNodeHeight: ASDimension = .init(unit: .points, value: 0.5)
        static let fieldHeight: ASDimension = .init(unit: .points, value: 40.0)
    }
    
    private let textFieldNode: ASDisplayNode = {
        let node = ASDisplayNode.init(viewBlock: {
            return UITextField.init(frame: .zero)
        })
        node.style.height = Const.fieldHeight
        return node
    }()
    
    private let indicatorLineNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.backgroundColor = .lightGray
        node.style.height = Const.indicatorLineNodeHeight
        return node
    }()
    
    private let messageNode: ASTextNode = {
        let node = ASTextNode()
        node.maximumNumberOfLines = 1
        node.isHidden = true
        return node
    }()
    
    public var textView: UITextField? {
        return self.textFieldNode.view as? UITextField
    }
    
    private let scope: SignUpFieldReactor.Scope
    public var disposeBag = DisposeBag()
    
    init(scope: SignUpFieldReactor.Scope) {
        defer { self.reactor = .init() }
        self.scope = scope
        super.init()
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = .white
    }
    
    func bind(reactor: SignUpFieldReactor) {
    
        self.textView?.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] _ in
                self?.indicatorLineNode.backgroundColor = .darkGray
            })
            .disposed(by: disposeBag)
        
        self.textView?.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .subscribe(onNext: { [weak self] _ in
                self?.indicatorLineNode.backgroundColor = .lightGray
            })
            .disposed(by: disposeBag)
        
        self.textView?.rx.controlEvent(.editingChanged)
            .map({ [weak self] _ -> SignUpFieldReactor.Action in
                return SignUpFieldReactor.Action.editingChanged(self?.scope, self?.textView?.text)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        let messageObservabe = reactor.state.map({ $0.message }).share()
        
        messageObservabe
            .bind(to: messageNode.rx.attributedText)
            .disposed(by: disposeBag)
            
        messageObservabe.map({ $0 == nil })
            .bind(to: messageNode.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    override func didLoad() {
        super.didLoad()
        self.textView?.returnKeyType = scope.returnKeyType
        self.textView?.clearButtonMode = .whileEditing
        self.textView?.clearsOnInsertion = scope.clearsOnInsertion
        self.textView?.isSecureTextEntry = scope.isSecureTextEntry
        self.textView?.placeholder = scope.placeholderString
    }
}

extension SignUpFieldNode {
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stackLayout = ASStackLayoutSpec(direction: .vertical,
                                            spacing: 0.5,
                                            justifyContent: .start,
                                            alignItems: .stretch,
                                            children: [textFieldNode, indicatorLineNode, messageNode])
        
        return ASWrapperLayoutSpec(layoutElement: stackLayout)
    }
}
