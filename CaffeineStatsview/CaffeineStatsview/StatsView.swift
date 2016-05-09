/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2016 cr0ss
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation
import UIKit

class StatsView: UIView {
    // MARK -
    internal var objects:Array<Double>?
    // MARK: - Constants
    private var useCatmullRom:Bool = true
    private let margin:CGFloat = 20.0
    private let topBorder:CGFloat = 10
    private let bottomBorder:CGFloat = 40
    private let graphBorder:CGFloat = 30
    private var intersectDistance:Int = 4

    override init (frame : CGRect) {
        super.init(frame : frame)
    }

    convenience init () {
        self.init(frame:CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func drawRect(rect: CGRect) {
        if let objects = self.objects {

            let graphHeight = rect.height - self.topBorder - self.bottomBorder - self.graphBorder
            let spacer = (rect.width - self.margin * 2) / CGFloat((objects.count-1))
            // Is there any maxValue?
            let maxValue:Int = Int(objects.maxElement() != nil ? objects.maxElement()! : 0.0)

            let columnXPoint = { (column:Int) -> CGFloat in
                var x:CGFloat = CGFloat(column) * spacer
                x += self.margin
                return x
            }
            let columnYPoint = { (graphPoint:Int) -> CGFloat in
                var y:CGFloat = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
                // Flip the graph
                y = graphHeight + self.topBorder + self.graphBorder - y
                return y
            }

            for index in 0 ..< Int(objects.count / self.intersectDistance) {
                let intersectHeight = (bounds.height - bottomBorder - topBorder)
                let intersectPath = UIBezierPath()

                let intersectStartPoint = CGPoint(x: columnXPoint(index * self.intersectDistance), y: bounds.height-bottomBorder)
                let intersectEndPoint = CGPoint(x: intersectStartPoint.x, y: intersectStartPoint.y - intersectHeight)
                intersectPath.moveToPoint(intersectStartPoint)
                intersectPath.addLineToPoint(intersectEndPoint)

                UIColor.clearColor().setStroke()
                intersectPath.lineWidth = 1.0
                intersectPath.stroke()

                //2 - get the current context
                let context = UIGraphicsGetCurrentContext()
                let colors = [UIColor.lightGrayColor().CGColor, UIColor.lightGrayColor().CGColor]
                //3 - set up the color space
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                //4 - set up the color stops
                let colorLocations:[CGFloat] = [0.0, 0.95]
                //5 - create the gradient
                let gradient = CGGradientCreateWithColors(colorSpace, colors, colorLocations)
                //save the state of the context
                CGContextSaveGState(context)
                CGContextSetLineWidth(context, intersectPath.lineWidth)
                CGContextAddPath(context, intersectPath.CGPath)
                CGContextReplacePathWithStrokedPath(context)
                CGContextClip(context)

                CGContextDrawLinearGradient(context, gradient, intersectStartPoint, intersectEndPoint, .DrawsAfterEndLocation)
                CGContextRestoreGState(context)
            }


            // draw the line graph
            UIColor.redColor().setFill()
            UIColor.redColor().setStroke()
            let graphPath = UIBezierPath()


            if(objects.count != 0) {
                if (self.useCatmullRom == false || objects.count < 4) {
                    // Draw Graph without Catmull Rom
                    graphPath.moveToPoint(CGPoint(x:columnXPoint(0), y:columnYPoint(Int(objects[0]))))
                    for i in 1..<objects.count {
                        let nextPoint = CGPoint(x:columnXPoint(i), y:columnYPoint(Int(objects[i])))
                        graphPath.addLineToPoint(nextPoint)
                    }
                } else {
                    // Implementation of Catmull Rom
                    let startIndex = 1
                    let endIndex = objects.count - 2
                    let alpha:CGFloat = 0.5
                    for i in startIndex ..< endIndex {
                        let p0 = CGPoint(x:columnXPoint(i-1 < 0 ? objects.count - 1 : i - 1), y:columnYPoint(Int(objects[i-1 < 0 ? objects.count - 1 : i - 1])))
                        let p1 = CGPoint(x:columnXPoint(i), y:columnYPoint(Int(objects[i])))
                        let p2 = CGPoint(x:columnXPoint((i+1) % objects.count), y:columnYPoint(Int(objects[(i+1)%objects.count])))
                        let p3 = CGPoint(x:columnXPoint((i+1) % objects.count + 1), y:columnYPoint(Int(objects[(i+1)%objects.count + 1])))

                        let d1 = p1.deltaTo(p0).length()
                        let d2 = p2.deltaTo(p1).length()
                        let d3 = p3.deltaTo(p2).length()

                        var b1 = p2.multiplyBy(pow(d1, 2 * alpha))
                        b1 = b1.deltaTo(p0.multiplyBy(pow(d2, 2 * alpha)))
                        b1 = b1.addTo(p1.multiplyBy(2 * pow(d1, 2 * alpha) + 3 * pow(d1, alpha) * pow(d2, alpha) + pow(d2, 2 * alpha)))
                        b1 = b1.multiplyBy(1.0 / (3 * pow(d1, alpha) * (pow(d1, alpha) + pow(d2, alpha))))

                        var b2 = p1.multiplyBy(pow(d3, 2 * alpha))
                        b2 = b2.deltaTo(p3.multiplyBy(pow(d2, 2 * alpha)))
                        b2 = b2.addTo(p2.multiplyBy(2 * pow(d3, 2 * alpha) + 3 * pow(d3, alpha) * pow(d2, alpha) + pow(d2, 2 * alpha)))
                        b2 = b2.multiplyBy(1.0 / (3 * pow(d3, alpha) * (pow(d3, alpha) + pow(d2, alpha))))

                        if i == startIndex {
                            graphPath.moveToPoint(p0)
                        }
                        graphPath.addCurveToPoint(p2, controlPoint1: b1, controlPoint2: b2)
                    }
                    let nextPoint = CGPoint(x:columnXPoint(objects.count - 1), y:columnYPoint(Int(objects[objects.count - 1])))
                    graphPath.addLineToPoint(nextPoint)
                }
            } else {
                // Draw a Line, when there are no Objects in the Array
                let zero = graphHeight + topBorder + graphBorder
                graphPath.moveToPoint(CGPoint(x:columnXPoint(0), y:zero))
                for i in 1..<objects.count {
                    let nextPoint = CGPoint(x:columnXPoint(i), y:zero)
                    graphPath.addLineToPoint(nextPoint)
                }
            }
        }
    }

    internal func setUpGraphView(statisticsItems:Array<Double>, intersectDistance:Int = 4, catmullRom:Bool = true) {
        self.objects = statisticsItems
        self.intersectDistance = intersectDistance
        self.useCatmullRom = catmullRom
        self.setNeedsDisplay()
    }
}

// MARK: - CGPoint Extension
extension CGPoint{
    func addTo(a: CGPoint) -> CGPoint {
        return CGPointMake(self.x + a.x, self.y + a.y)
    }

    func deltaTo(a: CGPoint) -> CGPoint {
        return CGPointMake(self.x - a.x, self.y - a.y)
    }

    func length() -> CGFloat {
        return CGFloat(sqrt(CDouble(self.x*self.x + self.y*self.y)))
    }

    func multiplyBy(value:CGFloat) -> CGPoint{
        return CGPointMake(self.x * value, self.y * value)
    }
}