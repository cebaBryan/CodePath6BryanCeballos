import UIKit
import PhotosUI
import ParseSwift
import CryptoKit

class PostViewController: UIViewController {
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!

    private var pickedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onPickedImageTapped(_ sender: UIBarButtonItem) {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @IBAction func onShareTapped(_ sender: Any) {
        guard let image = pickedImage, let imageData = image.jpegData(compressionQuality: 0.1) else { return }

        guard let imageHash = image.sha256() else {
            showAlert(description: "Unable to generate image hash.")
            return
        }

        // Disable the share button to prevent multiple uploads
        shareButton.isEnabled = false
        
        checkImageUniqueness(hash: imageHash) { [weak self] isUnique in
            DispatchQueue.main.async {
                if isUnique {
                    self?.uploadImage(imageData: imageData)
                } else {
                    self?.showAlert(description: "This photo has already been uploaded. Please select a different photo.")
                
                    self?.shareButton.isEnabled = true
                }
            }
        }
    }


    private func uploadImage(imageData: Data) {
        let imageFile = ParseFile(name: "image.jpg", data: imageData)
        var post = Post()
        post.imageFile = imageFile
        post.caption = captionTextField.text
        post.user = User.current
        
        post.save { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let savedPost):
                    print("✅ Post Saved! \(savedPost)")
                    self?.updateUserPhotoUploadFlag()
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }

    private func updateUserPhotoUploadFlag() {
        guard var currentUser = User.current else { return }
        currentUser.hasUploadedPhoto = true
        currentUser.save { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("User photo upload flag updated successfully.")
                case .failure(let error):
                    print("Failed to update user photo upload flag: \(error.localizedDescription)")
                }
            }
        }
    }

    func checkImageUniqueness(hash: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://parseapi.back4app.com/functions/checkImageUniqueness") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("DhGNwUwOXUidn15jOAX6avbCCiDXgNRpBqeVut1i", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("UcpN69QDt62KnqgZZ6QO9x6uWEjWfFCKXSIzwrhz", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["hash": hash]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(false)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let result = json["result"] as? Bool {
                    completion(result)
                } else {
                    completion(false)
                }
            } catch {
                completion(false)
            }
        }.resume()
    }

    @IBAction func onViewTapped(_ sender: Any) {
        view.endEditing(true)
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: description ?? "Please try again...", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            DispatchQueue.main.async {
                guard let self = self, let image = object as? UIImage else {
                    self?.showAlert(description: "Failed to load image.")
                    return
                }
                self.previewImageView.image = image
                self.pickedImage = image
            }
        }
    }
}

extension UIImage {
    func sha256() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 0.8) else { return nil }
        let hash = SHA256.hash(data: imageData)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
