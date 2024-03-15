import UIKit
import ParseSwift

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private var posts = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryPosts()
    }

    private func queryPosts() {
        guard let _ = User.current?.hasUploadedPhoto else {
            showAlert(description: "Please upload a photo to view the feed.")
            return
        }
        
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
        
        query.find { [weak self] result in
            switch result {
            case .success(let posts):
                self?.posts = posts
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedViewCell", for: indexPath) as? FeedViewCell else {
            fatalError("Unable to dequeue FeedViewCell")
        }
        cell.configure(with: posts[indexPath.row])
        return cell
    }

    @IBAction func onLogOutTapped(_ sender: Any) {
            showConfirmLogoutAlert()
        }

        private func showConfirmLogoutAlert() {
            let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
            let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
                NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(logOutAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        }

    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: description ?? "Please try again...", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
