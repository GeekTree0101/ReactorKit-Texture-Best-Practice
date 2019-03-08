import AsyncDisplayKit
import ReactorKit
import RxCocoa_Texture

class SignUpNodeController: ASViewController<SignUpContainerNode> {

    init() {
        super.init(node: .init())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

