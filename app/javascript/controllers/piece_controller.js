import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['piece'];
    static classes = ['available', 'selected'];

    initialize() {
        this.piece = null;
        this.selectMode = false;
    }

    connect() {
        // console.log(this.pieceTargets, "targets connect !");
    }

    select(event) {
        this.removeClass(this.availableClass);
        this.removeClass(this.selectedClass);

        if (!this.selectMode) {
            this.piece = event.target;
            this.piece.classList.add(this.selectedClass);
            this.selectMode = true
            let moves = JSON.parse(this.piece.dataset.pieceMoves || "[]");

            // render moves available to piece on board
            this.displayAvailableMoves(moves);            
        } else if (this.selectMode && this.piece) {
            const {pieceId, pieceX, pieceY} = this.piece?.dataset
            this.movePiece(pieceId, pieceX, pieceY)

            this.selectMode = false
        } else {
            this.piece = event.target;
            this.piece.classList.add(this.selectedClass);            
        }

    }

    displayAvailableMoves(moves){
        this.pieceTargets.forEach((element) => {
            let elX = Number(element.dataset.pieceX),
                elY = Number(element.dataset.pieceY);

            if (this.matchByPosition(elX, elY, moves)) {        
                element.classList.add(this.availableClass);
            }
        })
    }

    removeClass(classes) {
        this.pieceTargets.forEach((element) => {
            element.classList.remove(classes);
        })
    }

    matchByPosition(x, y, moves) {
        let bool = false;

        moves.forEach((move) => {
            if (move[0] == x && move[1] == y) {
                bool = true;
            }
        })

        return bool;
    }

    displayPieces(){
        this.pieceTargets.forEach((element, index) => {
            console.log(element.dataset.pieceX, element.dataset.pieceY)
        })
    }

    movePiece(id, x, y) {
        // add fetch/post request to update controller
        console.log(id, x, y)
    }
}