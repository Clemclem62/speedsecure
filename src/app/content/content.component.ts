import { Component, HostListener, OnInit } from '@angular/core';

@Component({
  selector: 'app-content',
  templateUrl: './content.component.html',
  styleUrls: ['./content.component.css']
})
export class ContentComponent implements OnInit {

  defaultValuePosition: number = 0;
  text1:             number = this.defaultValuePosition;
  text2:             number = this.defaultValuePosition;
  text3:             number = this.defaultValuePosition;
  text4:             number = this.defaultValuePosition;
  text5:             number = this.defaultValuePosition;
  text6:             number = this.defaultValuePosition;
  text7:             number = this.defaultValuePosition;
  text8:             number = this.defaultValuePosition;
  text9:             number = this.defaultValuePosition;
  text10:             number = this.defaultValuePosition;
  text11:             number = this.defaultValuePosition;

constructor() { }

ngOnInit(): void {
}

@HostListener('window:scroll', ['$event']) scroll(event: any){
  //console.log(window.scrollY);
  const y:     number = window.scrollY;
  const label: number = y/20;
  if(window.scrollY > 850) {
      this.text1 = 0.2;
  }
  if(window.scrollY > 950) {
    this.text1 = 0.5;
  }
  if(window.scrollY > 1050) {
    this.text1 = 0.7;
  }
  if(window.scrollY > 1150) {
    this.text1 = 1;
    this.text2 = 0.2;
  }
  if(window.scrollY > 1250) {
    this.text2 = 0.5;
  }
  if(window.scrollY > 1350) {
    this.text2 = 0.7;
  }
  if(window.scrollY > 1450) {
    this.text2 = 1;
    this.text3 = 0.2;
  }
  if(window.scrollY > 1550) {
    this.text3 = 0.5;
  }
  if(window.scrollY > 1650) {
    this.text3 = 0.7;
  }
  if(window.scrollY > 1750) {
    this.text3 = 1;
    this.text4 = 0.2;
  }
  if(window.scrollY > 1850) {
    this.text4 = 0.5;
  }
  if(window.scrollY > 1950) {
    this.text4 = 0.7;
  }
  if(window.scrollY > 2050) {
    this.text4 = 1;
    this.text5 = 0.2;
  }
  if(window.scrollY > 2150) {
    this.text5 = 0.5;
  }
  if(window.scrollY > 2250) {
    this.text5 = 0.7;
  }
  if(window.scrollY > 2350) {
    this.text5 = 1;
    this.text6 = 0.2;
  }
  if(window.scrollY > 2450) {
    this.text6 = 0.5;
  }
  if(window.scrollY > 2550) {
    this.text6 = 0.7;
  }
  if(window.scrollY > 2650) {
    this.text6 = 1;
    this.text7 = 0.2;
  }
  if(window.scrollY > 2750) {
    this.text7 = 0.5;
  }
  if(window.scrollY > 2850) {
    this.text7 = 0.7;
  }
  if(window.scrollY > 2950) {
    this.text7 = 1;
    this.text8 = 0.2;
  }
  if(window.scrollY > 3050) {
    this.text8 = 0.5;
  }
  if(window.scrollY > 3150) {
    this.text8 = 0.7;
  }
  if(window.scrollY > 3250) {
    this.text8 = 1;
    this.text9 = 0.2;
  }
  if(window.scrollY > 3350) {
    this.text9 = 0.5;
  }
  if(window.scrollY > 3450) {
    this.text9 = 0.7;
  }
  if(window.scrollY > 3550) {
    this.text9 = 1;
    this.text10 = 0.2;
  }
  if(window.scrollY > 3650) {
    this.text10 = 0.5;
  }
  if(window.scrollY > 3750) {
    this.text10 = 0.7;
  }
  if(window.scrollY > 3850) {
    this.text10 = 1;
    this.text11 = 0.2;
  }
  if(window.scrollY > 3950) {
    this.text11 = 0.5;
  }
  if(window.scrollY > 4050) {
    this.text11 = 0.7;
  }
  if(window.scrollY > 4150) {
    this.text11 = 1;
  }
}


}
