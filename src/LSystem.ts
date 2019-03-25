import ExpansionRule from './ExpansionRule';
import DrawRule from './DrawRule';
import {vec3, mat4, mat3, vec4, vec2} from 'gl-matrix';
import Turtle from './Turtle';
//import { transformMat4 } from 'gl-matrix/src/gl-matrix/vec2';
class Point {
    x: number;
    y: number;
    constructor (x: number, y: number) {
        this.x = x;
        this.y = y;
    }
};
//////////////////////
/////////////////////////
///////////////////
class Edge {
    start: Point;
    end: Point;
    rotation: number;
    isStreet: boolean;
    constructor (start: Point, end: Point, rotation: number, isStreet: boolean) {
        this.start = start;
        this.end = end;
        this.rotation = rotation;
        this.isStreet = isStreet;
    }
}

class LSystem {
    
    expansion: string;
    angleMod: number;
    
    edges: Set<Edge>;
    mainHead: Point;
    mainAngle: number;
    offset: number;
    

    constructor (angle: number, x: number, y: number) {
        console.log("made lsystem");
        this.offset = 0.05;
        this.mainHead = new Point(x - this.offset, y );
        this.edges = new Set<Edge>();
        this.edges.add(new Edge(new Point(x, y), new Point(x - this.offset, y), -1.57, false));
        this.mainAngle = -1.57;
        
        this.angleMod = angle;
        
    }

    

    mix(a: number, b: number, t: number) {
        return a * (1 - t) + b * t;
    }

    fract(value: number): number {
        return value - Math.floor(value)
    }

    noise(n: vec2): number {
        return (this.fract(Math.sin(vec2.dot(n, vec2.fromValues(12.9898, 4.1414))) * 43758.5453));
    }
    
    interpNoise2D(x: number, y: number, seed: number): number {
        let intX = Math.floor(x);
        let fractX = this.fract(x);
        let intY = Math.floor(y);
        let fractY = this.fract(y);
        //float seed = 1.0;
    
        let v1 = this.noise(vec2.fromValues(seed * intX, seed * intY));
        let v2 = this.noise(vec2.fromValues(seed * (intX + 1.0), seed * intY));
        let v3 = this.noise(vec2.fromValues(seed * intX, seed * (intY + 1.0)));
        let v4 = this.noise(vec2.fromValues(seed * (intX + 1.0), seed * (intY + 1.0)));
    
        let i1 = this.mix(v1, v2, fractX);
        let i2 = this.mix(v3, v4, fractX);
        return this.mix(i1, i2, fractY);
        
    }

    
    
    
    
    
    fbm(x: number, y: number, seed: number): number
    {
        let total = 0.0;
        let persistance = 0.5;
        let octaves = 8;
    
        for (var i = 0; i < octaves; i++) {
            let freq = Math.pow(2,  i);
            let amp = Math.pow(persistance, i);
    
            total += (this.interpNoise2D(x * freq, y * freq, seed)) * amp;
        }
        return (total + 1.0) / 2.0;
    }

    popNoise(x: number, y: number) {
        
        return Math.pow(this.fbm(y, x, 2.3) - 0.5, 1.5);
    }

    grid(recurse: number, start: Point, angle: number) {
        if (recurse == 0) {
            return; 
        }
        this.edges.add(new Edge(start, new Point(start.x - this.offset, start.y), -1.57, true));
        this.edges.add(new Edge(start, new Point(start.x, start.y + this.offset), 0, true));
        this.edges.add(new Edge(start, new Point(start.x  + this.offset, start.y), 1.57, true));
        this.edges.add(new Edge(start, new Point(start.x , start.y - this.offset), 3.14, true));

        this.grid(recurse - 1, new Point(start.x - this.offset, start.y), angle - 1.57);
        this.grid(recurse - 1, new Point(start.x, start.y + this.offset), angle);
        this.grid(recurse - 1, new Point(start.x  + this.offset, start.y), angle + 1.57);
    }

    expand(n: number) {
        let oldX = this.mainHead.x;
        let oldY = this.mainHead.y;
        
        let newY = Math.cos(this.mainAngle - 1.57) * (this.offset) + oldY;
        let newX = Math.sin(this.mainAngle - 1.57) * (this.offset) + oldX;
        let greatestPop = this.popNoise(newX, newY);
        let finalX = newX;
        let finalY = newY;
        let finalAngle = this.mainAngle - 1.57 ;
        for (var i = 1; i < 7; i++) {
            newY = Math.cos(this.mainAngle - 1.57 + 0.523 * i * this.angleMod) * (this.offset) + oldY;
            newX = Math.sin(this.mainAngle - 1.57 + 0.523 * i  * this.angleMod) * (this.offset) + oldX;
            let currentPop = this.popNoise(newX, newY);
            if (currentPop < greatestPop) {
                greatestPop = currentPop;
                finalX = newX;
                finalY = newY;
                finalAngle = this.mainAngle - 1.57 + 0.523 * i  * this.angleMod;
            }
        }
        
        this.edges.add(new Edge(this.mainHead, new Point(finalX, finalY), finalAngle, false));
        this.mainHead = new Point(finalX, finalY);
        this.mainAngle = finalAngle;
        
        
        
    }

    drawMatrices(gridIter: number): mat4[] {
        

        let output: mat4[] = new Array<mat4>();
        let streetStarts: Edge[] = new Array<Edge>();
        
        let count = 1;

        for (let current of this.edges) {
            if (count % 3 == 0) {
                streetStarts.push(current);
            }
            count += 1;
        }
        
        for (let edge of streetStarts) {
            this.grid(gridIter, edge.start, edge.rotation);
        }
        
        for (let current of this.edges) {
            
            
            

            
            let translate: mat4 =  mat4.create();
            let rotate: mat4 =  mat4.create();
            mat4.identity(translate);
            mat4.identity(rotate);
            
            mat4.translate(translate, translate, vec3.fromValues(current.start.x, current.start.y, 0.0));

            let opposite = current.end.y - current.start.y;
            let adjecent = current.end.x - current.start.x;
            let angle = Math.atan(opposite/adjecent);

            mat4.rotateZ(rotate, rotate, -current.rotation);
            console.log("rotation");
            console.log(current.rotation);
            let transformation: mat4 = mat4.create();
            mat4.identity(transformation);
            
            mat4.multiply(transformation, transformation, translate);
            mat4.multiply(transformation, transformation, rotate);
            let scale: mat4 = mat4.create();
            mat4.identity(scale);
            mat4.scale(scale, scale, vec3.fromValues(0.3, 0.5, 1));
            if (current.isStreet) {
                mat4.multiply(transformation, transformation, scale);
            }


            let test = vec4.fromValues(0, 0, 0, 1);
            vec4.transformMat4(test, test, transformation);
            mat4.identity(scale);
            mat4.scale(scale, scale, vec3.fromValues(0.01, 0.025, 0.001));
            vec4.transformMat4(test, test, scale)

            
            let startLandNoise = this.fbm(current.start.x , current.start.y, 1.0 ) * 0.4;
            let endLandNoise = this.fbm(current.end.x , current.end.y, 1.0 ) * 0.4;  

            
                output.push(transformation);
            

            
            
            console.log("/////////////////////");
            count += 1;
         
        }
        
        return output;
    }
}


export default LSystem;