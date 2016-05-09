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

class DetailViewController: UIViewController {
    @IBOutlet var statsView: StatsView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!

    internal var objects:Array<Double>? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    internal var indexPath:NSIndexPath? {
        didSet {
            self.setupLabels()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        self.setupLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func configureView() {
        // Update the user interface for the objects item.
        if let objects = self.objects {
            if self.statsView != nil {
                self.statsView.setUpGraphView(objects, intersectDistance:0)
            }
        }
    }

    private func setupLabels() {
        if let objects = self.objects, indexPath = self.indexPath {
            if self.detailDescriptionLabel != nil {
                self.detailDescriptionLabel.text = "Current Value: \(objects[indexPath.row])"
            }
        }
    }
}
