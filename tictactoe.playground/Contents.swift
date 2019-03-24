import UIKit
import PlaygroundSupport

var turn = true

class Space: UIView {
    var selection = "empty"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(paperWidth: CGFloat, row: Int, col: Int) {
        let width = paperWidth / 3
        let x = CGFloat(row) * width
        let y = CGFloat(col) * width
        let frame = CGRect(x:x, y: y, width: width, height: width)
        self.init(frame:frame)
        superSpace(row: row, col: col)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Space.didTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    func superSpace(row: Int, col: Int) {
        if row % 2 == col % 2 {
            self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        else {
            self.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.2431372549, blue: 0.3137254902, alpha: 1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setSelection(change: String) {
        if selection == "empty" {
            let selectionFrame = CGRect(x: self.frame.width / 4, y: self.frame.width / 4, width: self.frame.width / 2, height: self.frame.height / 2)
            
            let selectionView = UIImageView(frame: selectionFrame)
            let XImage = UIImage(named: "x")
            let OImage = UIImage(named: "o")
            
            if change == "x" {
                selection = "x"
                selectionView.image = XImage
            }
                
            else {
                selection = "o"
                selectionView.image = OImage
            }
            
            turn = !turn
            
            UIView.transition(with: self, duration: 0.5, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
                self.addSubview(selectionView)
            }, completion: nil )
            
        }
        else {
            print("Space is taken!")
        }
    }
    
    func setWin(x: Bool) {
        let selectionFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        let winFrame = UIView(frame: selectionFrame)
        
        if (x) {
            winFrame.backgroundColor = #colorLiteral(red: 0, green: 0.8344659675, blue: 0, alpha: 0.5)
        }
        else {
            winFrame.backgroundColor = #colorLiteral(red: 1, green: 0.6856538955, blue: 0.1965164812, alpha: 0.5)
        }
        
        UIView.transition(with: self, duration: 1, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
            self.addSubview(winFrame)
        }, completion: nil )
        
        
    }
    
    func getSelection() -> String {
        return selection
    }
    
    @objc func didTap(_ sender: UITapGestureRecognizer) {
        let controller = PlaygroundPage.current.liveView as! thisGame
        
        let row = Int(sender.location(in: controller).x / self.frame.width)
        let col = Int(sender.location(in: controller).y / self.frame.width)
        
        if turn {
            setSelection(change: "x")
        }
        else {
            setSelection(change: "o")
        }
        
        controller.winner(row: row, col: col)
    }
}

class thisGame: UIView {
    var paper = Array(repeating: Array(repeating: Space(), count: 3), count: 3)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    convenience init() {
        let viewFrame = CGRect(x: 0, y: 0, width: 600, height: 600)
        self.init(frame: viewFrame)
        
        self.backgroundColor = .white
        resetPaper(first: true)
    }
    
    @objc func resetPaper(first: Bool) {
        
        for view in self.subviews {
            UIView.transition(with: self, duration: 1, options: [.transitionFlipFromTop, .curveEaseOut], animations: {
                view.removeFromSuperview()
            }, completion: nil)
        }
        
        for row in 0...2 {
            for col in 0...2 {
                paper[row][col] = Space(paperWidth: self.frame.width, row: row, col: col)
                self.addSubview(paper[row][col])
            }
        }
    }
    
    func winner(row: Int, col: Int) {
        var winningMoves = [[Int]]()
        var totalCount = 0
        
        if paper[0][col].getSelection() == paper[1][col].getSelection() && paper[1][col].getSelection() == paper[2][col].getSelection() && paper[0][col].getSelection() != "empty" {
            winningMoves += [[0, col], [1, col], [2, col]]
        }
        
        else if paper[row][0].getSelection() == paper[row][1].getSelection() && paper[row][1].getSelection() == paper[row][2].getSelection() && paper[row][0].getSelection() != "empty" {
            winningMoves += [[row, 0], [row, 1], [row, 2]]
        }
        
        else if paper[0][0].getSelection() == paper[1][1].getSelection() && paper[1][1].getSelection() == paper[2][2].getSelection() && paper[0][0].getSelection() != "empty" {
            winningMoves += [[0, 0], [1, 1], [2, 2]]
        }
        
        else if paper[2][0].getSelection() == paper[1][1].getSelection() && paper[1][1].getSelection() == paper[0][2].getSelection() && paper[2][0].getSelection() != "empty" {
            winningMoves += [[2, 0], [1, 1], [0, 2]]
        }
        
        else {
            for spaces in paper {
                for space in spaces {
                    if space.getSelection() == "x" || space.getSelection() == "o" {
                        totalCount += 1
                    }
                }
            }
        }
        
        for move in winningMoves {
            paper[move[0]][move[1]].setWin(x: !turn)
        }
        
        if !winningMoves.isEmpty || totalCount == 9 {
            
            Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(resetPaper), userInfo: nil, repeats: false)
            
            for spaces in paper {
                for space in spaces {
                    space.isUserInteractionEnabled = false
                }
            }
        }
    }
}

PlaygroundPage.current.liveView = thisGame()
