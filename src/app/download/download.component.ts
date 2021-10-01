import { Component, OnInit } from '@angular/core';
import { saveAs } from 'file-saver';

@Component({
    selector: 'app-download',
    templateUrl: './download.component.html',
    styleUrls: ['./download.component.css']
})
export class DownloadComponent implements OnInit {

    constructor() { }

    ngOnInit(): void {
        this.download();
    }

    download() {
        const script = '../../ressources/speedsecure.sh';
        const scriptName = 'speedsecure.sh';
        saveAs(script, scriptName);
    }

}
