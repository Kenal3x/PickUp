//
//  EnvironmentChildViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/6/21.
//

import UIKit

//this is the little pop up to select a basketball court of soccer field

protocol EnvironmentChildViewControllerDelegate {
    func filterAnnotations(sport: String)
}


class EnvironmentChildViewController: UIViewController {
    

    var delegate: EnvironmentChildViewControllerDelegate?
    var hasSetPointOrigin = false
     var pointOrigin: CGPoint?
     
    @IBOutlet weak var basketballButton: UIButton!
    @IBOutlet weak var soccerButton: UIButton!
    override func viewDidLoad() {
         super.viewDidLoad()
         let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
         view.addGestureRecognizer(panGesture)
        
        Utilities.styleFilledButton(soccerButton)
        Utilities.styleFilledButton(basketballButton)
    
     }
     
    @IBAction func basketballTapped(_ sender: Any) {
        //triggers the filter
        self.delegate?.filterAnnotations(sport: "basketball")
        dismiss(animated: true, completion: nil)
    }
    @IBAction func soccerTapped(_ sender: Any) {

        //triggers the filter
        self.delegate?.filterAnnotations(sport: "soccer")
        dismiss(animated: true, completion: nil)
        print("soccer")

        
        
    }
    override func viewDidLayoutSubviews() {
         if !hasSetPointOrigin {
             hasSetPointOrigin = true
             pointOrigin = self.view.frame.origin
         }
        
    
        
        
     }
     @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
         let translation = sender.translation(in: view)
         
         // Not allowing the user to drag the view upward
         guard translation.y >= 0 else { return }
         
         // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
         view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
         
         if sender.state == .ended {
             let dragVelocity = sender.velocity(in: view)
             if dragVelocity.y >= 1300 {
                 self.dismiss(animated: true, completion: nil)
             } else {
                 // Set back to original position of the view controller
                 UIView.animate(withDuration: 0.3) {
                     self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                 }
             }
         }
     }
 }
