//
//  TokenInputViewController.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 26/07/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import UIKit

private enum Sport:String {
   case Football, Tennis, Hockey, Basketball
    
    func emoji() -> String {
        switch self {
        case .Football : return "⚽️"
        case .Tennis : return "🎾"
        case .Hockey : return "🏒"
        case .Basketball : return "🏀"
        }
    }
}

class TokenInputViewController:DetailViewController {
    
    @IBOutlet weak var tokenView:TokenInputView!
    @IBOutlet weak var tableView:UITableView!
    
    fileprivate let names:[(String,String,Sport)] = [
        ("André", "Agassi", .Tennis),
        ("Pete", "Sampras", .Tennis),
        ("Boris", "Becker", .Tennis),
        ("Roger", "Federer", .Tennis),
        ("John", "McEnroe", .Tennis),
        ("Michael", "Jordan", .Basketball),
        ("Lebron", "James", .Basketball),
        ("Kobe", "Bryant", .Basketball),
        ("Tony","Parker", .Basketball),
        ("Zinedine", "Zidane", .Football),
        ("Luis", "Figo", .Football),
        ("","Ronaldo", .Football),
        ("", "Pele", .Football),
        ("Sidney","Crosby", .Hockey),
        ("Patrick","Kane", .Hockey),
        ("P.K.","Subban", .Hockey),
        ("Carey","Price", .Hockey),
        ("Alexander","Ovechkin", .Hockey),
        ("Roberto","Luongo", .Hockey),
        ("Henrik","Sedin", .Hockey),
        ("Jaromir","Jagr", .Hockey),
        ("Henrik","Lundqvist", .Hockey)
        ].sorted{$0.1 < $1.1}
    
    fileprivate var filteredNames = [(String,String,Sport)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tokenView.placeholder = "Entre a name"
        tokenView.fieldName = "To: "
        tokenView.delegate = self
        
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension TokenInputViewController:TokenInputViewDelegate {
    
    func tokenInputViewDidBegingEditing(_ view: TokenInputView) {

    }
    
    func tokenInputViewDidEndEditing(_ view: TokenInputView) {

    }
    
    func tokenInputView(_ view: TokenInputView, didRemove token: Token) {
        
    }
    
    func tokenInputView(_ view: TokenInputView, didAddToken token: Token) {
        
    }
    
    func tokenInputView(_ view: TokenInputView, didChangeText text: String?) {
        if let text = text {
            tableView.isHidden = false
            filteredNames = names.filter({"\($0.0) \($0.1)".range(of: text, options:.caseInsensitive) != nil})
        } else {
            tableView.isHidden = true
            filteredNames.removeAll()
        }
        tableView.reloadData()
    }
}

extension TokenInputViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let name = filteredNames[(indexPath as NSIndexPath).row]
        let fontSize:CGFloat = 16
        let attr = [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)]
        let attrString = NSMutableAttributedString(string: name.0 + " ", attributes:attr)
        
        let boldAttr = [NSFontAttributeName:UIFont.boldSystemFont(ofSize: fontSize)]
        attrString.append(NSAttributedString(string: name.1, attributes: boldAttr))
        cell.textLabel?.attributedText = attrString

        
        if cell.accessoryView == nil {
            cell.accessoryView = UILabel()
        }
        guard let emojiLabel = cell.accessoryView as? UILabel else {
            return cell
        }
        emojiLabel.text = name.2.emoji()
        emojiLabel.sizeToFit()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let name = filteredNames[(indexPath as NSIndexPath).row]
        let token = Token(string: "\(name.0) \(name.1)")
        tokenView.addToken(token)
    }
}
