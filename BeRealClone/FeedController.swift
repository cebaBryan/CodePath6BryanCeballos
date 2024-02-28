import UIKit
import ParseSwift

class FeedController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var posts = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate and data source
        tableView.delegate = self
        tableView.dataSource = self

        // Register the FeedCell class with the table view
        tableView.register(FeedCell.self, forCellReuseIdentifier: "FeedCell")

        tableView.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        queryPosts()
    }

    private func queryPosts() {
        // Your post query logic
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

    @IBAction func onLogOutTapped(_ sender: Any) {
        showConfirmLogoutAlert()
    }

    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            // Implement the log out functionality
            // Assuming you have a logout function in User
            User.logout { result in
                switch result {
                case .success:
                    print("Successfully logged out.")
                    // Perform segue or update UI accordingly
                case .failure(let error):
                    self.showAlert(description: "Logout failed: \(error.localizedDescription)")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension FeedController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a cell of the type FeedCell with the identifier "FeedCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as? FeedCell else {
            fatalError("The dequeued cell is not an instance of FeedCell.")
        }
        // Configure the cell with the post
        cell.configure(with: posts[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FeedController: UITableViewDelegate {
    // Implement any delegate methods you need
}
