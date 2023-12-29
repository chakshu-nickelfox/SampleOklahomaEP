//
//  ViewController.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import UIKit
import ReactiveCocoa
import FLUtilities

protocol ExamPrepHomePageViewControllerDelegate: AnyObject {
    func goto(viewController: ListType)
    func clearAllReports()
    func clearStudyDeck()
    func checkReportsAvailable()
    func checkChapterInStudyDesk()
    func reportsAvailable() -> Bool
}

class ExamPrepHomePageViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var practiceView: UIView!
    @IBOutlet weak var studyDeckView: UIView!
    @IBOutlet weak var reportsView: UIView!
    @IBOutlet weak var practiceImageView: UIImageView!
    @IBOutlet weak var studyDeckImageView: UIImageView!
    @IBOutlet weak var reportsImageView: UIImageView!
    @IBOutlet weak var reviewDeckLabel: UILabel!
    @IBOutlet weak var practiceExamLabel: UILabel!
    @IBOutlet weak var viewReportsLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var bgGradientView: UIView!
    @IBOutlet weak var appLogoImageView: UIImageView!
    @IBOutlet weak var appLogoImageViewWidthConstraint: NSLayoutConstraint!
    
    var viewModel: ExamPrepHomePageViewControllerDelegate!
    
    static var newInstance: ExamPrepHomePageViewController? {
        let sb = UIStoryboard.init(name: Storyboard.examPrep.name,
                                   bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: self.className()) as? ExamPrepHomePageViewController
        return vc
    }
    
    var verticalMenu = OptionsSheetView.newInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constant.ExamPrep.examPrep
        self.setupViewModel()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.verticalMenu?.hideSelf()
    }
    
    private func setupViewModel() {
        if self.viewModel == nil {
            self.viewModel = ExamPrepHomePageViewModel(self)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setupGradient()
    }
    
    func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.1, 0.5]
        self.bgGradientView.layer.sublayers?.removeAll() //  reset layer to handle orientation changes
        self.bgGradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupUI() {
        self.practiceExamLabel.setFont(FontType.h16)
        self.reviewDeckLabel.setFont(FontType.h16)
        self.viewReportsLabel.setFont(FontType.h16)
        self.practiceView.roundedCornerForExamPrep()
        self.studyDeckView.roundedCornerForExamPrep()
        self.reportsView.roundedCornerForExamPrep()
        self.practiceImageView.backgroundColor = UIColor.black
        self.studyDeckImageView.backgroundColor = UIColor.black
        self.reportsImageView.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.tabBarController?.tabBar.isHidden = false
        self.setupGestureOnBackgroundView()
        
        self.appLogoImageView.image = Image.IAP.appLogoIPhone.image
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.appLogoImageViewWidthConstraint.constant = 285.0
        } else {
            self.appLogoImageViewWidthConstraint.constant = 170.0
        }
    }
    
    func setupGestureOnBackgroundView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.dimView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.verticalMenu?.hideSelf()
        self.dimView.isHidden = true
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .overFullScreen
    }
    
    @IBAction func menuActionButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func redirectToPracticeExamList(_ sender: UIButton) {
        self.goToChapterListViewController(.practiceExam)
    }
    
    @IBAction func redirectToExamReports(_ sender: UIButton) {
        if self.viewModel.reportsAvailable() {
            self.viewModel.goto(viewController: .reports)
        } else {
            self.showAlert(message: Constant.ExamPrep.noReports)
        }
    }
    
    @IBAction func redirectToStudyDeckList(_ sender: UIButton) {
        self.viewModel.goto(viewController: .studyDeckList)
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        let verticalMenu = OptionsSheetView.newInstance
        guard let verticalMenuInstance = verticalMenu else { return }
        self.verticalMenu = verticalMenu
        verticalMenuInstance.delegate = self
        verticalMenuInstance.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(verticalMenuInstance)
        self.setupSettingsOnTopOfTabBar(menu: verticalMenuInstance)
        self.showDimOnSelf()
    }
    
    func setupSettingsOnTopOfTabBar(menu: OptionsSheetView) {
        NSLayoutConstraint.activate([
            menu.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -90),
            menu.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            menu.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            menu.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    func showDimOnSelf() {
        self.dimView.isHidden = false
    }
}

// MARK: - ExamPrepHomePageViewModelDelegate
extension ExamPrepHomePageViewController: ExamPrepHomePageViewModelDelegate {
    
    func testReports(available: Bool) {
        if available {
            let yesAction = ActionInterface(title: Constant.yes, style: .default)
            let noAction = ActionInterface(title: Constant.no)
            self.showAlert(title: Constant.ExamPrep.reset,
                           message: Constant.ExamPrep.clearReports,
                           actionInterfaceList: [yesAction, noAction],
                           handler: { interface in
                if interface.title == yesAction.title {
                    self.viewModel.clearAllReports()
                    self.dismissOnOk(message: Constant.ExamPrep.reportsCleared) { }
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
                    self.dismissOnOk(message: Constant.ExamPrep.studyDeckCleared) { }
                }
            })
        } else {
            self.showAlert(message: Constant.ExamPrep.studyDeskEmpty)
        }
    }

    private func goToChapterListViewController(_ navigationType: NavigationType) {
        guard let vc = ChapterListViewController.newInstance else { return }
        let viewModel = ChapterListViewModel(vc)
        viewModel.navigationType = navigationType
        vc.viewModel = viewModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func show(selectedList: ListType) {
        switch selectedList {
        case .reports:
            guard let vc = ReportsViewController.newInstance else { return }
            self.navigationController?.pushViewController(vc, animated: true)
        case .studyDeckList:
            self.goToChapterListViewController(.studyDeck)
        case .examPrep:
            self.goToChapterListViewController(.practiceExam)
        }
    }
    
    func reports(available: Bool) {
        if available {
            guard let vc = ReportsViewController.newInstance else { return }
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            self.showAlert(message: Constant.ExamPrep.noReports)
        }
    }
}

// MARK: - OptionsSheetViewDelegate
extension ExamPrepHomePageViewController: OptionsSheetViewDelegate {
    
    func removeDimmedView() {
        self.dimView.isHidden = true
    }
    
    func didSelected(option: SheetActionType) {
        if option == .clearStudyDeck {
            self.viewModel.checkChapterInStudyDesk()
        } else {
            self.viewModel.checkReportsAvailable()
        }
    }
    
}

