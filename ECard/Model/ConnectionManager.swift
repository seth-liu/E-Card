//  ConnectionManager.swift
//  ECard

import Foundation
import MultipeerConnectivity

protocol ConnectionManagerDelegate {
    func receivedUserID(id: String)
}

class ConnectionManager: NSObject{
    var isActive: Bool = false
    
    let session: MCSession
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    var username: String = ""
    
    var delegate: ConnectionManagerDelegate?
    
    let service = "softtrak-ecard"
    var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser?
    var nearbyServiceBrowser: MCNearbyServiceBrowser?
    
    override init() {
        session = MCSession(
          peer: myPeerId,
          securityIdentity: nil,
          encryptionPreference: .none)
        
        super.init()
        
        session.delegate = self
    }
    
    func setUsername(username: String){
        self.username = username
    }
    
    func activate(id: String) {
        if (!isActive) {
            isActive = true
            
            session.disconnect()
            
            self.username = id
            
            nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: service)
            nearbyServiceBrowser?.delegate = self
            nearbyServiceBrowser?.startBrowsingForPeers()
            
            nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: ["id": id, "session_count": String(session.connectedPeers.count)], serviceType: service)
            nearbyServiceAdvertiser?.delegate = self
            nearbyServiceAdvertiser?.startAdvertisingPeer()
        }
    }
    
    func deactivate() {
        if (isActive){
            isActive = false

            nearbyServiceAdvertiser?.stopAdvertisingPeer()
            nearbyServiceBrowser?.stopBrowsingForPeers()
        }
    }
    
    func send() {
        let data = username.data(using: .utf8)!

        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch let error {
            print(error)
        }
    }
}

extension ConnectionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if (state == MCSessionState.connected) {
            print(peerID)
            
            send()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        self.delegate?.receivedUserID(id: String(data: data, encoding: .utf8)!)
        
        send()
        
        session.disconnect()
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

extension ConnectionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
            deactivate()
            
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30.0)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
}

extension ConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
            deactivate()
            
            invitationHandler(true, self.session)
    }
}
