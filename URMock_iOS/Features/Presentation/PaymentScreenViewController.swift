import UIKit
import SnapKit

class PaymentScreenViewController: UIViewController {
    
    private let paymentId: String
    private let paymentService: PaymentServiceProtocol
    private var paymentInfo: PaymentInfo?

    // UI
    private let amountLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let payButton = UIButton(type: .system)

    // MARK: - Init
    
    init(paymentId: String, paymentService: PaymentServiceProtocol = RealPaymentService()) {
        self.paymentId = paymentId
        self.paymentService = paymentService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        fetchPaymentInfo()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        amountLabel.font = .systemFont(ofSize: 32, weight: .bold)
        amountLabel.textAlignment = .center
        amountLabel.textColor = .customBlack
        
        descriptionLabel.font = .systemFont(ofSize: 18, weight: .regular)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 0
        
        payButton.setTitle("Оплатить", for: .normal)
        payButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        payButton.backgroundColor = .accent
        payButton.setTitleColor(.customBlack, for: .normal)
        payButton.layer.cornerRadius = 12
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        
        view.addSubview(amountLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(payButton)
        
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.left.right.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        payButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
    }
    
    // MARK: - API
    
    private func fetchPaymentInfo() {
        paymentService.fetchPaymentInfo(paymentId: paymentId) { [weak self] result in
            switch result {
            case .success(let info):
                self?.paymentInfo = info
                self?.updateUI()
            case .failure(let error):
                print("Error fetching payment info:", error)
            }
        }
    }
    
    private func updateUI() {
        guard let info = paymentInfo else { return }
        amountLabel.text = info.amount > 0 ? "\(info.amount) ₽" : "Не указана сумма"
        descriptionLabel.text = info.description
    }
    
    @objc private func payButtonTapped() {
        guard paymentInfo != nil else { return }
        
        paymentService.pay(paymentId: paymentId) { [weak self] result in
            switch result {
            case .success:
                self?.showAlert(title: "Успех", message: "Платёж прошёл успешно!")
            case .failure(let error):
                self?.showAlert(
                    title: "Ошибка",
                    message: "Не удалось выполнить платёж: \(error.localizedDescription)"
                )
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}
