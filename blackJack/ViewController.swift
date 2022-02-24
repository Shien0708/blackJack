//
//  ViewController.swift
//  blackJack
//
//  Created by 方仕賢 on 2022/2/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var betLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet var bankerCardImageViews: [UIImageView]!
    @IBOutlet var playerCardImageViews: [UIImageView]!
    
    @IBOutlet weak var backCardImageView: UIImageView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var doubleButton: UIButton!
    var openedCards = [String]()
    var nums = [Int]()
    
    // d = spade, c = heart, b = diamond, a = club
    let codes = ["d", "c", "b", "a"]
    var suits = [String]()
    var image = 0
    
    var player = [String]()
    var banker = [String]()
    
    var playerValue = 0
    var bankerValue = 0
    
    var total = 5000
    var bet = 0
    @IBOutlet weak var betStepper: UIStepper!
    @IBOutlet weak var giveUPButton: UIButton!
    
    @IBOutlet weak var insuranceButton: UIButton!
    @IBOutlet weak var insuranceStepper: UIStepper!
    @IBOutlet weak var insuranceLabel: UILabel!
    @IBOutlet weak var insuranceView: UIView!
    @IBOutlet weak var okButton: UIButton!
    
    @IBOutlet weak var bankerValueLabel: UILabel!
    @IBOutlet weak var playerValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        for i in 0...playerCardImageViews.count-1{
          playerCardImageViews[i].alpha = 0
            bankerCardImageViews[i].alpha = 0
        }
        backCardImageView.alpha = 0
        shuffleCards()
    }

    //洗牌及補牌
    func shuffleCards(){
        
        for suit in 0...3 {
            for num in 1...13 {
                nums.append(num)
                suits.append(codes[suit])
            }
        }
        nums.shuffle()
        suits.shuffle()
    }
    
    //首輪發牌
    func firstServe(){
        var cardImage = 0
        var time = 0
        for _ in 0...1 {
            time += 1
            serveBanker(image: cardImage,time: cardImage+1)
            time += 1
            servePlayer(image: cardImage, time: time)
           cardImage += 1
        }
    }
    
    //重新一輪
    func again(){
        image = 0
        player = []
        banker = []
        playerValue = 0
        bankerValue = 0
        for i in 0...playerCardImageViews.count-1 {
            playerCardImageViews[i].image = UIImage(named: "")
            bankerCardImageViews[i].image = UIImage(named: "")
            playerCardImageViews[i].alpha = 0
            bankerCardImageViews[i].alpha = 0
        }
        backCardImageView.alpha = 0
        hideButtons()
        betStepper.isHidden = false
        resultLabel.text = ""
        playerValueLabel.text = "0"
        bankerValueLabel.text = "0"
    }
    
    //發牌給玩家
    func servePlayer(image: Int, time: Int) {
        
        //補足卡牌
        if nums.count < 10 {
            shuffleCards()
        }
        
        player.append("\(suits[0]+String(nums[0]))")
        playerCardImageViews[image].image = UIImage(named: "\(player[image])")
        
        let animator = UIViewPropertyAnimator(duration: TimeInterval(time), curve: .linear) {
            self.playerCardImageViews[image].alpha = 1
        }
        animator.startAnimation()
        
        //人像為十點
        if nums[0] == 13 || nums[0] == 12 || nums[0] == 11 {
            nums[0] = 10
        }
        
        //一點為十一點
        
        
        if nums[0] == 1 {
            if bankerValue < 11 {
                nums[0] = 11
            }
        }
        
        playerValue += nums[0]
        
        nums.removeFirst()
        suits.removeFirst()
        
        playerValueLabel.text = "\(playerValue)"
    }
    
    //發牌給莊家
    func serveBanker(image: Int, time: Int){
        if image == 1 {
           nums[0] = 1
           banker.append("\(suits[0]+String(nums[0]))")
        }
        banker.append("\(suits[0]+String(nums[0]))")
        bankerCardImageViews[image].image = UIImage(named: "\(banker[image])")
        
        //蓋牌
        let animator = UIViewPropertyAnimator(duration: TimeInterval(time), curve: .linear) {
                self.bankerCardImageViews[image].alpha = 1
            }
            animator.startAnimation()
        
        
        //人像為十點
        if nums[0] == 13 || nums[0] == 12 || nums[0] == 11 {
            nums[0] = 10
        }
        
        //一點為十一點
        if nums[0] == 1 && nums[1] == 10 {
            if bankerValue < 11 {
                nums[0] = 11
            }
        } else if nums[0] == 10 && nums[1] == 1 {
            if bankerValue < 11 {
                nums[1] = 11
            }
        }
        
        bankerValue += nums[0]
        
        nums.removeFirst()
        suits.removeFirst()
    }
    
    //準備重來
    func readyToAgain(){
        _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            self.again()
        }
    }
    
    //玩家輸贏賭金結果
    func playerResult(win: Bool, times: Float){
        //贏的話根據倍數獲得獎金
        if win == true {
            total += Int(times*Float(bet))
            totalLabel.text = "\(total)"
            resultLabel.text! += "\n玩家獲得 $\(Int(times*Float(bet)))"
        } else {
            if resultLabel.text != "平手" {
                resultLabel.text! += "\n玩家損失 $\(bet)"
            }
        }
        
        bet = 0
        betLabel.text = "\(bet)"
        betStepper.maximumValue = Double(total)
        betStepper.value = 0
        
    }
    
    //檢查莊家手牌狀況
    func checkBanker(){
        //爆牌
        if bankerValue > 21 {
            resultLabel.text = "莊家爆牌"
            playerResult(win: true, times: 2)
         //黑傑克
        } else if bankerValue == 21 {
            
            resultLabel.text = "莊家 Black Jack!"
            playerResult(win: false, times: 0)
        } else {
            //莊家手牌大
            if bankerValue > playerValue {
                resultLabel.text = "莊家獲勝"
                playerResult(win: false, times: 0)
                //玩家手牌大
            } else if bankerValue < playerValue {
                resultLabel.text = "玩家獲勝"
                playerResult(win: true, times: 2)
                //平手
            } else {
                resultLabel.text = "平手"
                total += bet
                totalLabel.text = "\(total)"
                bet = 0
                betStepper.maximumValue = Double(total)
                betStepper.value = 0
                betLabel.text = "\(bet)"
            }
            
        }
        hideButtons()
        readyToAgain()
        bankerValueLabel.text = "\(bankerValue)"
    }
    
    //檢查玩家手牌狀況
    func checkPlayer(){
        if playerValue > 21 {
            resultLabel.text = "玩家爆牌"
            callButton.isHidden = true
            readyToAgain()
            playerResult(win: false, times: 0)
            hideButtons()
        } else if playerValue == 21 {
            resultLabel.text = "玩家 Black Jack!"
            callButton.isHidden = true
            readyToAgain()
            playerResult(win: true, times: 2.5)
            hideButtons()
        }
    }
    
    //更改賭金
    @IBAction func changeBet(_ sender: UIStepper) {
        betLabel.text = "\(Int(sender.value))"
        bet = Int(sender.value)
        total = Int(sender.maximumValue)-bet
        totalLabel.text = "\(total)"
        if sender.value == 0 {
            callButton.isHidden = true
        } else {
            callButton.isHidden = false
        }
    }
    
    //隱藏按鈕
    func hideButtons(){
        callButton.isHidden = true
        stopButton.isHidden = true
        giveUPButton.isHidden = true
        insuranceButton.isHidden = true
        doubleButton.isHidden = true
    }
    
    //叫牌
    @IBAction func call(_ sender: Any) {
        betStepper.isHidden = true
        callButton.isHidden = false
        giveUPButton.isHidden = false
        stopButton.isHidden = false
        //蓋牌
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
            self.backCardImageView.alpha = 1
        }
        animator.startAnimation()
        //首次發牌
        if image == 0 {
            firstServe()
            image += 2
            checkPlayer()
        } else if image < 5 {
            servePlayer(image: image, time: 1)
            image += 1
            checkPlayer()
            //過五關
            if image == 5 && playerValue <= 21 {
                playerResult(win: true,times: 3)
                resultLabel.text = "玩家過五關！"
                hideButtons()
                readyToAgain()
            }
        }  
        
        //加注
        if playerValue == 11 {
            doubleButton.isHidden = false
        }
        //保險
        if resultLabel.text?.contains("點") == true {
            insuranceButton.isHidden = true
        } else if banker[1].contains("1") && banker[1].count == 2 && total > 500 && playerValue < 21 {
            insuranceButton.isHidden = false
        }
       
        checkIsBankrupt()
    }
    
    //檢查是否破產
    func checkIsBankrupt(){
        if total <= 0 && bet == 0 {
            let controller = UIAlertController(title: "You're bankrupt", message: "Try Again", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { action in
                self.total = 5000
                self.totalLabel.text = "\(self.total)"
                self.betStepper.maximumValue = Double(self.total)
                self.again()
            }
            controller.addAction(action)
            present(controller, animated: true, completion: nil)
        }
    }
    
    //停牌
    @IBAction func stop(_ sender: Any) {
        image = 2
        hideButtons()
        //開莊家首張牌
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
            self.backCardImageView.alpha = 0
        }
        animator.startAnimation()
        
        //莊家點數不足17點時需補發牌
        if bankerValue < 17 {
            while bankerValue < 17 && image != 5 {
                serveBanker(image: image, time: 1)
                image += 1
            }
            checkBanker()
        } else {
            checkBanker()
        }
        checkIsBankrupt()
    }
    
    //放棄本輪
    @IBAction func giveUp(_ sender: Any) {
        hideButtons()
        betStepper.isHidden = true
        total += bet/2
        resultLabel.text = "玩家棄牌\n玩家損失 $\(bet/2)"
        bet = 0
        
        totalLabel.text = "\(total)"
        betLabel.text = "\(bet)"
        betStepper.value = 0
        betStepper.maximumValue = Double(total)
        
        readyToAgain()
    }
    
    //加注
    @IBAction func double(_ sender: Any) {
        hideButtons()
        total -= bet
        bet *= 2
        totalLabel.text = "\(total)"
        betStepper.maximumValue = Double(total)
        betStepper.value = 0
        betLabel.text = "\(bet)"
        servePlayer(image: 2, time: 1)
        checkPlayer()
        if playerValue < 21 {
            stop((Any).self)
        }
    }
    
    //使用保險
    @IBAction func insure(_ sender: Any) {
        insuranceView.isHidden = false
        okButton.isHidden = true
        insuranceStepper.maximumValue = Double(total)
    }
    
    //調整保險金
    @IBAction func makeInsurance(_ sender: UIStepper) {
        total = Int(insuranceStepper.maximumValue) - Int(insuranceStepper.value)
        totalLabel.text = "\(total)"
        insuranceLabel.text = "\(Int(insuranceStepper.value))"
        
        if sender.value == 0 {
            okButton.isHidden = true
        } else {
            okButton.isHidden = false
        }
    }
    
    //使用保險金檢查是否莊家為黑傑克
    @IBAction func checkIsBlackJack(_ sender: Any) {
        if bankerValue == 21 {
            insuranceStepper.value *= 2
            total += Int(insuranceStepper.value)
           
            resultLabel.text = "莊家為 21 點\n玩家獲得 $\(Int(insuranceStepper.value))"
            
            
        } else {
            resultLabel.text = "莊家非 21 點\n玩家損失 $\(Int(insuranceStepper.value))"
            insuranceStepper.value = 0
        }
        
        insuranceLabel.text = "0"
        insuranceStepper.maximumValue = 0
        insuranceView.isHidden = true
        insuranceButton.isHidden = true
    }
    
    
}

