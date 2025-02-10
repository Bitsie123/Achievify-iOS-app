//
//  ChatViewController.swift
//  Achievify3
//
//  Created by Marks on 18/09/2024.
//

/* REFERENCE
    iOS Academy (2020) Chat Messages in App (Swift 5) Xcode 11 - iOS,
    YouTube.
    Available at: https://www.youtube.com/watch?v=6v4fmg9iRSU
 */
import UIKit
import MessageKit
import InputBarAccessoryView


// MARK: MessasgeKit
// Struct to represent a message sender
struct Sender: SenderType, Codable {
    var senderId: String
    var displayName: String
}

// Struct to represent a chat message
struct Message: MessageType, Codable {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
/* REFERENCE
    Lets Build That App (2016) Swift: Firebase 3 - How to Implement Interactive Keyboard using inputAccessoryView (Ep 15),
    YouTube.
    Available at: https://www.youtube.com/watch?v=ky7YRh01by8
*/
    enum CodingKeys: String, CodingKey {
        case sender
        case messageId
        case sentDate
        case kind
    }
    
    // Initializer for creating a Message instance
    init(sender: SenderType, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
    
/* REFRENCE
    Apple Developer (2023) Having proper message functionality with parse, UIKit and MessageKit, Having Proper Message Functionality with Parse, UIKit and MessageKit
    Apple Developer Forums.
    Available at: https://forums.developer.apple.com/forums/thread/728704
*/
    // Save the sent message as plain text
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sender as? Sender, forKey: .sender)
        try container.encode(messageId, forKey: .messageId)
        try container.encode(sentDate, forKey: .sentDate)
        
        if case let .text(text) = kind {
            try container.encode(text, forKey: .kind)
        }
    }
    
    // Load messages
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sender = try container.decode(Sender.self, forKey: .sender)
        let messageId = try container.decode(String.self, forKey: .messageId)
        let sentDate = try container.decode(Date.self, forKey: .sentDate)
        let kindText = try container.decode(String.self, forKey: .kind)
        self.init(sender: sender, messageId: messageId, sentDate: sentDate, kind: .text(kindText))
    }
}

class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    // Define current user and other users within chat
    let currentUser = Sender(senderId: "self", displayName: "You")
    let otherUser1 = Sender(senderId: "other1", displayName: "Jake")
    let otherUser2 = Sender(senderId: "other2", displayName: "Chloe")
    
    // Store messages
    var messages = [MessageType]()
    let userDefaultsKey = "chatMessages"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* REFERENCE
         
         */
        // Layout adjustments
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
        
        // Set the title
        self.title = "Taper Chat"
        
        // Set data source and delegate
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        // Set input bar delegate
        messageInputBar.delegate = self
        
        // Load saved messages
        loadMessages()
        
        // Reload collection view data
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
    }
    
    // Save messages
    func saveMessages() {
        let encoder = JSONEncoder()
        if let encodedMessages = try? encoder.encode(messages as! [Message]) {
            UserDefaults.standard.set(encodedMessages, forKey: userDefaultsKey)
        }
    }
    
    // Load messages
    func loadMessages() {
        if let savedMessagesData = UserDefaults.standard.data(forKey: userDefaultsKey) {
            let decoder = JSONDecoder()
            if let decodedMessages = try? decoder.decode([Message].self, from: savedMessagesData) {
                messages = decodedMessages
            }
        } else {
            // If no messages are saved, add default ones
            messages.append(Message(sender: currentUser,
                                    messageId: "1",
                                    sentDate: Date().addingTimeInterval(-86400),
                                    kind: .text("Hey guys!")))
            
            messages.append(Message(sender: otherUser2,
                                    messageId: "2",
                                    sentDate: Date().addingTimeInterval(-7000),
                                    kind: .text("Awh hey! How's it going?")))
            
            messages.append(Message(sender: otherUser1,
                                    messageId: "3",
                                    sentDate: Date().addingTimeInterval(-6400),
                                    kind: .text("Good good, how're ye all doing?")))
            
            messages.append(Message(sender: currentUser,
                                    messageId: "4",
                                    sentDate: Date().addingTimeInterval(-6000),
                                    kind: .text("I'm really starting to feel the effects of tapering. My legs feel fresh but I'm worried about losing my endurance.")))
            
            messages.append(Message(sender: otherUser1,
                                    messageId: "5",
                                    sentDate: Date().addingTimeInterval(-5500),
                                    kind: .text("Tapering can definitely feel strange. It's normal to have mixed feelings, but it helps in the long run. Wanna do a run together later today? Maybe 3 ish?")))
        }
    }
    
    
    // MARK: - MessagesDataSource Methods
    func currentSender() -> SenderType {
        // Current user as sender
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    // MARK: - MessagesDisplayDelegate Methods
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
        )
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 35
    }
}


// MARK: - InputBarAccessoryViewDelegate Methods
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // Create new message with the text inp0ut
        let newMessage = Message(sender: currentSender(), messageId: UUID().uuidString, sentDate: Date(), kind: .text(text))
        messages.append(newMessage)
        
        // Save the new message
        saveMessages()
        
        // Reload data
        messagesCollectionView.reloadData()
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToLastItem()
    }
}
