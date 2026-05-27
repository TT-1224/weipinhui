
export default class ItemData {
  /**
   * Text of list item.
   */
  title: Resource;
  /**
   * Image of list item.
   */
  img: Resource;
  /**
   * Other resource of list item.
   */
  others?: string | Resource;

  cardPrice?: number | Resource;

  brandName?: string;

  constructor(title: Resource, img: Resource, others?: string | Resource, cardPrice?: number | Resource, brandName?: string) {
    this.title = title;
    this.img = img;
    this.others = others;
    this.cardPrice = cardPrice;
    this.brandName = brandName;
  }

  /*constructor(title: Resource, img: Resource, cardId: String) {
    this.title = title;
    this.img = img;
    this.cardId = cardId;
  }
  */

}