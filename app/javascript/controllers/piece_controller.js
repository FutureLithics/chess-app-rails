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

            this.setSelect();
        } else if (this.selectMode && this.piece) {
            let item = this.parseItem(this.piece?.dataset);
            const x = event.target.dataset.pieceX;
            const y = event.target.dataset.pieceY;
            const inAvailableMoves = item?.available_moves.filter((move) => {
                return move[0] == x && move[1] == y;
            })
            
            if(item && inAvailableMoves.length > 0) {
                const id = item.id;

                this.movePiece(id, x, y)                
            }


            this.selectMode = false
        } else {
            this.piece = event.target;
            this.piece.classList.add(this.selectedClass);            
        }

    }

    parseItem(data) {
        let item = data?.pieceItem

        if (item) {
            return JSON.parse(item);
        } else {
            return false;
        }
    }

    setSelect() {
        let item = this.parseItem(this.piece?.dataset);

        if (item) {
            this.selectMode = true

            // render moves available to piece on board
            this.displayAvailableMoves(item?.available_moves);                 
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

        const csrfToken = document.querySelector("[name='csrf-token']").content
        const moveParams = {
            piece_id: id,
            position_x: x,
            position_y: y
        }

        fetch(`/move`, {
            method: 'PUT', // *GET, POST, PUT, DELETE, etc.
            mode: 'cors', // no-cors, *cors, same-origin
            cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
            credentials: 'same-origin', // include, *same-origin, omit
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken
            },
            body: JSON.stringify({ move: moveParams  }) // body data type must match "Content-Type" header
        })
        .then(res => res.json())
        .then((res) =>  console.log(res, "move?"))
    }
}