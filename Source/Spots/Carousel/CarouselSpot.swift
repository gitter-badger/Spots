import UIKit
import GoldenRetriever
import Sugar

class CarouselSpot: NSObject, Spotable {

  static var cells = [String: UICollectionViewCell.Type]()

  var component: Component
  weak var sizeDelegate: SpotSizeDelegate?

  lazy var flowLayout: UICollectionViewFlowLayout = {
    let size = UIScreen.mainScreen().bounds.width / CGFloat(self.component.span)
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    layout.itemSize = CGSize(width: floor(size), height: 125)
    layout.scrollDirection = .Horizontal

    return layout
    }()

  lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.flowLayout)
    collectionView.frame.size.width = UIScreen.mainScreen().bounds.width
    collectionView.dataSource = self
    collectionView.backgroundColor = UIColor.whiteColor()

    return collectionView
    }()

  required init(component: Component) {
    self.component = component
    super.init()
    for item in component.items {
      let componentCellClass = GridSpot.cells[item.type] ?? UICollectionViewCell.self
      self.collectionView.registerClass(componentCellClass, forCellWithReuseIdentifier: "CarouselCell\(item.type)")
    }
  }

  func render() -> UIView {
    collectionView.frame.size.height = flowLayout.itemSize.height

    return collectionView
  }

  func layout(size: CGSize) {
    let newSize = size.width / CGFloat(self.component.span)
    flowLayout.itemSize = CGSize(width: floor(newSize), height: flowLayout.itemSize.height)
    collectionView.frame.size.width = size.width
  }
}

extension CarouselSpot: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return component.items.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let item = component.items[indexPath.item]

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CarouselCell\(item.type)", forIndexPath: indexPath)

    for view in cell.contentView.subviews { view.removeFromSuperview() }

    if item.image != "" {
      let resource = item.image
      let fido = GoldenRetriever()
      let qualityOfServiceClass = QOS_CLASS_BACKGROUND
      let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)

      dispatch(backgroundQueue) {
        fido.fetch(resource) { data, error in
          guard let data = data else { return }
          let image = UIImage(data: data)
          dispatch {
            cell.backgroundColor = UIColor(patternImage: image!)
          }
        }
      }
    } else {
      cell.backgroundColor = UIColor.lightGrayColor()
    }

    let label = UILabel(frame: CGRect(x: 0,y: 0,
      width: flowLayout.itemSize.width,
      height: flowLayout.itemSize.height))
    label.text = item.title
    label.textAlignment = .Center
    cell.contentView.addSubview(label)

    return cell
  }
}