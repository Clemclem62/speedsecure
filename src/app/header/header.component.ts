import { Component, HostListener, OnInit } from '@angular/core';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css']
})
export class HeaderComponent implements OnInit {

    defaultValuePosition: number = 18;
    position1:             number = this.defaultValuePosition;
    position2:             number = this.defaultValuePosition;

    defaultValueImage: number = 2;
    image1:             number = this.defaultValueImage;
    image2:             number = this.defaultValueImage;

  constructor() { }

  ngOnInit(): void {
  }

  @HostListener('window:scroll', ['$event']) scroll(event: any){
    // console.log(event);
    // console.log("scrolling : ", window.scrollY);
    const y:     number = window.scrollY;
    // const label: number = Math.min(Math.floor(y/20));
    const label: number = y/20;
    if(this.defaultValuePosition - label > 0) {
        this.position1 = this.defaultValuePosition - label;
        this.position2 = this.defaultValuePosition - label;
        console.log(label);
        if(label < 7){
          this.image1 = 2;
          this.image2 = 2;
        }
        if(label > 7){
          this.image1 = 0.7;
          this.image2 = 0.7;
        }
        if(label > 9){
          this.image1 = 0.5;
          this.image2 = 0.5;
        }
        if(label > 11){
          this.image1 = 0.2;
          this.image2 = 0.2;
        }
        if(label > 13){
          this.image1 = 0;
          this.image2 = 0;
        }
    }
  }


}
