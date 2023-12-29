//
//  MenuSheetViewController.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import UIKit
import ReactiveSwift
import FLUtilities

protocol MenuSheetViewControllerDelegate: AnyObject {
    var disposable: CompositeDisposable { get }
    var sectionCount: Int { get }
    
    func rowCount(at section: Int) -> Int
    func section(at index: Int) -> SectionModel
    func cellModel(at indexPath: IndexPath) -> Any
    func didSelectRow(at indexPath: IndexPath)
    func loadSheetOptions()
    func clearAllReports()
    func clearStudyDeck()
}

protocol MenuSheetActionDelegate: AnyObject {
    func didTapDeleteAll()
    func didTapDownloadAll()
}

class MenuSheetViewController: UIViewController {
    
    let maxDimmedAlpha: CGFloat = 0.3
    var defaultHeight: CGFloat = 0
    let rowHeight: CGFloat = 65.0
    let padding: CGFloat = 35.0
    
    @IBOutlet weak var sheetTitleLabel: UILabel!
    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var dimmedView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    
    var viewModel: MenuSheetViewControllerDelegate!
    weak var delegate: MenuSheetActionDelegate?
    
    static var newInstance: MenuSheetViewController? {
        let sb = UIStoryboard.init(name: Storyboard.menuSheet.name,
                                   bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: self.className()) as? MenuSheetViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    
    private func initialSetup() {
        self.setupConstraints()
        self.setupPanGesture()
        self.setupViewModel()
        self.setupObservers()
        self.setupTableView()
    }
    
    private func setupTableView() {
        self.optionsTableView.delegate = self
        self.optionsTableView.dataSource = self
        self.optionsTableView.registerCell(MenuTableViewCell.self)
        self.optionsTableView.estimatedRowHeight = rowHeight
        self.optionsTableView.rowHeight = UITableView.automaticDimension
        self.optionsTableView.tableFooterView = UIView()
    }
    
    private func setupViewModel() {
        if self.viewModel == nil {
            self.viewModel = MenuSheetViewModel(self, menuOptions: [])
        }
        self.viewModel.loadSheetOptions()
    }
    
    private func setupObservers() {
    }
    
}

// MARK: - UITableViewDelegate
extension MenuSheetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.didSelectRow(at: indexPath)
    }
}

// MARK: - UITableViewDataSource
extension MenuSheetViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.rowCount(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let reusableId = self.reusableIdentifier(at: indexPath) else {
            return UITableViewCell()
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: reusableId) as? TableViewCell {
            cell.item = self.viewModel.cellModel(at: indexPath)
            cell.delegate = self
            return cell
        }
        
        return UITableViewCell()
    }
    
    private func reusableIdentifier(at indexPath: IndexPath) -> String? {
        let cellModel = self.viewModel.cellModel(at: indexPath)
        switch cellModel {
        case _ as MenuTableViewCellModel:
            return MenuTableViewCell.defaultReuseIdentifier
        default: return nil
        }
    }
    
}

// MARK: - MenuSheetViewModelDelegate
extension MenuSheetViewController: MenuSheetViewModelDelegate {
    
    func reports(available: Bool) {
        if available {
            let yesAction = ActionInterface(title: Constant.yes, style: .default)
            let noAction = ActionInterface(title: Constant.no)
            self.showAlert(title: Constant.reset,
                           message: Constant.ExamPrep.clearReports,
                           actionInterfaceList: [yesAction, noAction],
                           handler: { interface in
                if interface.title == yesAction.title {
                    self.viewModel.clearAllReports()
                    self.dismissOnOk(message: Constant.ExamPrep.reportsCleared) {
                        self.animateDismissView()
                    }
                }
            })
        } else {
            self.showAlert(message: Constant.ExamPrep.noReports)
        }
    }
    
    func studyDeckChapters(available: Bool) {
        if available {
            let yesAction = ActionInterface(title: Constant.yes, style: .default)
            let noAction = ActionInterface(title: Constant.no)
            self.showAlert(title: Constant.ExamPrep.reset,
                           message: Constant.ExamPrep.clearStudyDesk,
                           actionInterfaceList: [yesAction, noAction],
                           handler: { interface in
                if interface.title == yesAction.title {
                    self.viewModel.clearStudyDeck()
                    self.dismissOnOk(message: Constant.ExamPrep.studyDeckCleared) {
                        self.animateDismissView()
                    }
                }
            })
        } else {
            self.showAlert(message: Constant.ExamPrep.studyDeskEmpty)
        }
    }
    
    func reloadSheet() {
        self.defaultHeight = (CGFloat(self.viewModel.rowCount(at: 0)) * rowHeight) + padding
        self.setupConstraints()
        self.animatePresentContainer()
        self.optionsTableView.reloadData()
    }
    
    func didTapDeleteAll() {
        self.delegate?.didTapDeleteAll()
        self.animateDismissView()
    }
    
    func didTapDownloadAll() {
        self.delegate?.didTapDownloadAll()
        self.animateDismissView()
    }
    
}

// MARK: - Gestures & Animation
extension MenuSheetViewController {
    func animatePresentContainer() {
        UIView.animate(withDuration: 0.3, delay: 0.2) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
        UIView.animate(withDuration: 0.5, delay: 0.3) {
            self.containerViewHeightConstraint?.constant = self.defaultHeight
            self.containerViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func setupConstraints() {
        containerViewBottomConstraint.constant = -defaultHeight
    }
    
    @objc func animateDismissView() {
        UIView.animate(withDuration: 0.2) {
            self.containerViewBottomConstraint?.constant = -self.defaultHeight
            self.view.layoutIfNeeded()
        }
        
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.2) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    func setupPanGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.animateDismissView))
        self.dimmedView.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Get drag direction
        let isDraggingDown = translation.y > 0
        
        switch gesture.state {
        case .ended:
            if isDraggingDown {
                self.animateDismissView()
            }
        default:
            break
        }
    }
    
}

class MenuTableViewCell: TableViewCell {
    
    @IBOutlet weak var optionTitleLAbel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func configure(_ item: Any?) {
        guard let model = item as? MenuTableViewCellModel else { return }
        self.optionTitleLAbel.text = model.title
        self.isUserInteractionEnabled = model.isAccessible
    }
    
}
