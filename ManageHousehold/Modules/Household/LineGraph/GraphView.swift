//
//  GraphView.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/14.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit

class GraphView: UIView, NibLoadable {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var maxAxisLabel: UILabel!
    @IBOutlet weak var minAxisLabel: UILabel!
    
    @IBOutlet weak var maxAxisLine: UIView!
    var maxPoint: CGFloat {
        return maxAxisLine.center.y
    }
    @IBOutlet weak var centerLine: UIView!
    var centerPoint: CGFloat {
        return centerLine.center.y
    }
    @IBOutlet weak var minAxisLine: UIView!
    var minPoint: CGFloat {
        return minAxisLine.center.y
    }
    var maxAxisValue = 10000 {
        didSet {
            self.maxAxisLabel.text = "\(maxAxisValue)"
        }
    }
    var minAxisValue = -10000 {
        didSet {
            self.minAxisLabel.text = "\(minAxisValue)"
        }
    }
    
    private let startColor: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    private let endColor: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    private let lineColor: UIColor = UIColor.black
    
    var graphPoints: [Int] = []
    var payments: [Payment] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadNib()
        setupView()
    }
    
    func setupView() {
        collectionView.register(cellType: GraphXAxisCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
        updateAxisValue(graphPoints)
    }
    
    func update(with payments: [Payment]) {
        var total = 0
        graphPoints = payments.map { payment in
            total += payment.total
            return total
        }
        updateAxisValue(graphPoints)
        
        self.payments = payments
        collectionView.reloadData()
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        drawBackgroundView()
        
        guard !graphPoints.isEmpty else {
            return
        }
        
        lineColor.setFill()
        lineColor.setStroke()
        
        let graphPath = UIBezierPath()
        graphPoints.enumerated().forEach { (offset, point) in
            guard offset != 0 else {
                graphPath.move(to: CGPoint(x:columnXPoint(column: offset),
                                           y:columnYPoint(graphPoint: point)))
                return
            }
            graphPath.addLine(to: CGPoint(x:columnXPoint(column: offset),
                                          y:columnYPoint(graphPoint: point)))
        }
        
        graphPath.lineWidth = 1.0
        graphPath.stroke()
    }
    
    func drawBackgroundView() {
        let path = UIBezierPath(roundedRect: frame,
                                byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: CGSize(width: 8.0, height: 8.0))
        path.addClip()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: self.bounds.height)
        context!.drawLinearGradient(gradient!,
                                    start: startPoint,
                                    end: endPoint,
                                    options: .drawsBeforeStartLocation)
    }
    
    func columnXPoint(column: Int) -> CGFloat {
        let cellWidth = collectionView.frame.width / CGFloat(graphPoints.count)
        return collectionView.frame.origin.x + (cellWidth * CGFloat(column)) + cellWidth / 2
    }
    
    func columnYPoint(graphPoint:Int) -> CGFloat {
        if graphPoint > 0 {
            let graphHeight = centerPoint - maxPoint
            let y = CGFloat(graphPoint) / CGFloat(maxAxisValue) * graphHeight
            return centerPoint - y
        } else {
            let graphHeight = minPoint - centerPoint
            let y = CGFloat(graphPoint) / CGFloat(minAxisValue) * graphHeight
            return centerPoint + y
        }
    }
    
    func updateAxisValue(_ graphPoints: [Int]) {
        guard let maxValue = graphPoints.max(), let minValue = graphPoints.min() else {
            return
        }
        let absValue = abs(maxValue) > abs(minValue) ? abs(maxValue) : abs(minValue)
        guard absValue != 0 else {
            maxAxisValue = 10000
            minAxisValue = -10000
            return
        }
        let absAxisValue = { () -> Int in
            var tempAxisValue = 1
            while tempAxisValue < absValue {
                tempAxisValue = tempAxisValue * 10
            }
            tempAxisValue = tempAxisValue / 10
            let temp = tempAxisValue / 10
            while tempAxisValue < absValue {
                tempAxisValue = tempAxisValue + temp
            }
            return tempAxisValue
        }()
        maxAxisValue = absAxisValue
        minAxisValue = -absAxisValue
    }
}

extension GraphView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return graphPoints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(with: GraphXAxisCell.self, for: indexPath)
        cell.setup("\(Calendar.current.component(.day, from: payments[indexPath.row].date))")
        return cell
    }
}

extension GraphView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.width / CGFloat(graphPoints.count)
        return CGSize(width: size, height: 28)
    }
}
