
import UIKit
class AboutThisAppViewController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logo.isUserInteractionEnabled = true
        logo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:))))
    }
    
    
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        guard let url = URL(string: "https://skart-inc.jimdofree.com/") else { return }
        UIApplication.shared.open(url)
    }
}
