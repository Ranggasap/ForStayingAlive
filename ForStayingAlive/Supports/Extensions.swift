//
//  Extensions.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 12/06/24.
//

import CoreGraphics

extension CGPoint {
	func distance(to point: CGPoint) -> CGFloat {
		return hypot(x - point.x, y - point.y)
	}
}
