//
//  SessionAdapter.swift
//  ECard
//
//  Created by David Lin on 2022-08-23.
//

import Foundation
import MultipeerConnectivity

class SessionAdapter: NSObject, MCSessionDelegate {
    var session:MCSession?
    // weak var delegate:PeerSessionDelegate?

    func setSession(_ session:MCSession) {
        self.session = session
        session.delegate = self
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {

    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}
