import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['piece']
    initialize() {
        this.piece = null;
        this.selectMode = true
    }

    connect() {
        // console.log(this.element, "pieces!")
    }

    select() {
        if (this.selectMode && this.data.get("id") !== this.piece) {
            this.piece = this.data.get("id");
            this.selectMode = false;

            // render moves available to piece on board

            console.log(this.data.get("moves"))
        }
    }

    displayPieces(){
        this.pieceTargets.forEach((element, index) => {
            console.log(element.dataset.pieceX, element.dataset.pieceY)
        })
    }
}