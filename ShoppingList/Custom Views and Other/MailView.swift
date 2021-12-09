//
//  MailView.swift
//  Chicago Bridge Scorer
//
//  Created by Mohammad Rahchamani on 4/5/1399 AP.
//  Copyright © 1399 AP BetterSleep. All rights reserved.
//  see https://github.com/mohammad-rahchamani/MailView
//

import Foundation
import MessageUI
import SwiftUI

public typealias AttachmentData = (Data, String, String)
public typealias MailViewResult = MFMailComposeResult

// this class was added by me to collect all 8 individual parameters for the MailView into
// a single place and simplify setting up a MailView in a .sheet.  neither this class nor its
// usage below was part of the original code of MailView.
public class MailViewData {
	var subject: String = ""
	var toRecipients: [String]? = nil
	var ccRecipients: [String]? = nil
	var bccRecipients: [String]? = nil
	var messageBody: String = ""
	var isHTML: Bool = false
	var attachments: [AttachmentData]? = nil
	var preferredSendingAddress: String = ""
	
	// use this function to clear out a previously used mail setup (added by me)
	func clear() {
		subject = ""
		toRecipients = nil
		ccRecipients = nil
		bccRecipients = nil
		messageBody = ""
		isHTML = false
		attachments = nil
		preferredSendingAddress = ""
	}
}


public struct MailView: UIViewControllerRepresentable {
	
	@Binding var isShowing: Bool
	
	let resultHandler: ((Result<MailViewResult, Error>) -> Void)?
	
	let mailViewData: MailViewData // simplified input data to collect the following parameters:
	//	let subject: String
	//
	//	let toRecipients: [String]?
	//	let ccRecipients: [String]?
	//	let bccRecipients: [String]?
	//
	//	let messageBody: String
	//	let isHtml: Bool
	//
	//	let attachments: [AttachmentData]?
	
	//	let preferredSendingAddress: String
	
	// MARK: init
	public init(isShowing: Binding<Bool>,
							mailViewData: MailViewData, // simplified input data to collect the parameters below
							resultHandler: ((Result<MailViewResult, Error>) -> Void)? = nil) {
		//	,
		//							subject: String = "",
		//							toRecipients: [String]? = nil,
		//							ccRecipients: [String]? = nil,
		//							bccRecipients: [String]? = nil,
		//							messageBody: String = "",
		//							isHtml: Bool = false,
		//							attachments: [AttachmentData]? = nil,
		//							preferredSendingAddress: String = "") {
		self._isShowing = isShowing
		
		self.mailViewData = mailViewData
		self.resultHandler = resultHandler
		
		// same: simplified input data copying of the parameters below
		//		self.subject = subject
		//
		//		self.toRecipients = toRecipients
		//		self.ccRecipients = ccRecipients
		//		self.bccRecipients = bccRecipients
		//
		//		self.messageBody = messageBody
		//		self.isHtml = isHtml
		//
		//		self.attachments = attachments
		
		//		self.preferredSendingAddress = preferredSendingAddress
	}
	
	public func makeCoordinator() -> Coordinator {
		Coordinator(isShowing: self.$isShowing,
								resultHandler: self.resultHandler)
	}
	
	// MARK: make view controller
	public func makeUIViewController(context: Context) -> MFMailComposeViewController {
		let viewController = MFMailComposeViewController()
		viewController.mailComposeDelegate = context.coordinator
		
		viewController.setSubject(mailViewData.subject)
		
		viewController.setToRecipients(mailViewData.toRecipients)
		viewController.setCcRecipients(mailViewData.ccRecipients)
		viewController.setBccRecipients(mailViewData.bccRecipients)
		
		viewController.setMessageBody(mailViewData.messageBody,
																	isHTML: mailViewData.isHTML)
		
		viewController.setPreferredSendingEmailAddress(mailViewData.preferredSendingAddress)
		
		for attachment in mailViewData.attachments ?? [] {
			viewController.addAttachmentData(attachment.0,
																			 mimeType: attachment.1,
																			 fileName: attachment.2)
		}
		return viewController
	}
	
	// MARK: update view controller
	public func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
		// nothing to do here.
	}
	
	// MARK: coordinator
	public class Coordinator: NSObject {
		
		@Binding var isShowing: Bool
		
		let resultHandler: ((Result<MailViewResult, Error>) -> Void)?
		
		init(isShowing: Binding<Bool>,
				 resultHandler: ((Result<MailViewResult, Error>) -> Void)? = nil) {
			self._isShowing = isShowing
			self.resultHandler = resultHandler
		}
		
	}
	
}

// MARK: coordinator extension
extension MailView.Coordinator: MFMailComposeViewControllerDelegate {
	
	public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		
		defer {
			self.isShowing = false
		}
		
		guard let error = error else {
			self.resultHandler?(.success(result))
			return
		}
		self.resultHandler?(.failure(error))
	}
	
}

// MARK: canSendMail extension
public extension MailView {
	
	static var canSendMail: Bool {
		MFMailComposeViewController.canSendMail()
	}
	
}

// MARK: safe mail view extension
public extension MailView {
	
	func safe() -> some View {
		
		let joinedRecipients = mailViewData.toRecipients?.joined(separator: ",") ?? ""
		
		var nextSeparator = "?"
		
		var joinedCc = ""
		if mailViewData.ccRecipients != nil {
			joinedCc = "\(nextSeparator)cc=" + mailViewData.ccRecipients!.joined(separator: ",")
			nextSeparator = "&"
		}
		
		var joinedBcc = ""
		if mailViewData.bccRecipients != nil {
			joinedBcc = "\(nextSeparator)bcc=" + mailViewData.bccRecipients!.joined(separator: ",")
			nextSeparator = "&"
		}
		
		let formattedSubject = "\(nextSeparator)subject=" +
			(mailViewData.subject.stringByAddingPercentEncodingForRFC3986() ?? "")
		
		let formattedBody = "&body=" +
			(mailViewData.messageBody.stringByAddingPercentEncodingForRFC3986() ?? "")
		
		let mailtoUrl = URL(string: "mailto:\(joinedRecipients)\(joinedCc)\(joinedBcc)\(mailViewData.subject.count > 0 ?  formattedSubject : "")\(mailViewData.messageBody.count > 0 ? formattedBody : "")")
		
		if !MailView.canSendMail {
			DispatchQueue.main.async {
				// dismiss modal view
				self.isShowing = false
			}
			if let url = mailtoUrl  {
				UIApplication.shared.open(url,
																	options: [:],
																	completionHandler: {
																		result in
																		if result {
																			// we have no idea if it's been sent.
																			self.resultHandler?(.success(.sent))
																		} else {
																			self.resultHandler?(.failure(MailViewError.openFailed))
																		}
																	})
			} else {
				self.resultHandler?(.failure(MailViewError.badUrl))
			}
			if let url = mailtoUrl  {
				UIApplication.shared.open(url,
																	options: [:],
																	completionHandler: { _ in})
			}
		}
		
		return Group {
			if MailView.canSendMail {
				self
			} else {
				EmptyView()
			}
		}
		
		
	}
	
}

// MARK: encode string
extension String {
	public func stringByAddingPercentEncodingForRFC3986() -> String? {
		let unreserved = "-._~/?"
		let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
		allowedCharacterSet.addCharacters(in: unreserved)
		return addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet)
	}
}

// MARK: custom errors
public enum MailViewError: Error {
	case badUrl
	case openFailed
}
