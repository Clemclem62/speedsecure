import { Component, OnInit } from '@angular/core';
import { MatSnackBar } from '@angular/material/snack-bar';

@Component({
    selector: 'app-get-started',
    templateUrl: './get-started.component.html',
    styleUrls: ['./get-started.component.css']
})
export class GetStartedComponent implements OnInit {

    constructor(private _snackBar: MatSnackBar, private clipboard: Clipboard) { }

    ngOnInit(): void {
    }

    openSnackBar = () => {
        this._snackBar.open('Lien copié', '', {
            duration: 2 * 1000,
            horizontalPosition: 'start',
            verticalPosition: 'bottom',
        });
    }

}
